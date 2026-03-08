// Supabase Edge Function: Parse Voice Recap
// Server-side parsing of voice transcripts against merchant's menu items

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface MenuItem {
  id: string
  name: string
  aliases?: string[]
  price: number
}

interface ParseRequest {
  transcript: string
  menuItems: MenuItem[]
  language?: string // 'ms' or 'en'
}

interface ParsedItem {
  menuItemId: string
  menuItemName: string
  quantity: number
  soldOut: boolean
  confidence: number
  matchedText: string
}

interface ParsedCash {
  amount: number
  isApproximate: boolean
  matchedText: string
}

interface ParseResponse {
  success: boolean
  items?: ParsedItem[]
  cash?: ParsedCash
  error?: string
}

// Malay number words mapping
const MALAY_NUMBERS: Record<string, number> = {
  'satu': 1, 'se': 1,
  'dua': 2,
  'tiga': 3,
  'empat': 4,
  'lima': 5,
  'enam': 6,
  'tujuh': 7,
  'lapan': 8,
  'sembilan': 9,
  'sepuluh': 10,
  'sebelas': 11,
  'dua belas': 12, 'duabelas': 12,
  'dua puluh': 20, 'duapuluh': 20,
  'tiga puluh': 30, 'tigapuluh': 30,
  'empat puluh': 40, 'empatpuluh': 40,
  'lima puluh': 50, 'limapuluh': 50,
}

// Sold out indicators
const SOLD_OUT_INDICATORS = [
  'habis', 'sold out', 'tak ada', 'takda', 'tiada',
  'kosong', 'out of stock', 'dah habis', 'sudah habis'
]

// Cash indicators
const CASH_INDICATORS = [
  'ringgit', 'rm', 'sen', 'duit', 'cash', 'tunai',
  'wang', 'total', 'jumlah', 'semua'
]

// Approximate indicators
const APPROXIMATE_INDICATORS = [
  'lebih kurang', 'dalam', 'around', 'about', 'roughly',
  'agak', 'approximately', 'anggaran', 'kira-kira'
]

function normalizeText(text: string): string {
  return text.toLowerCase()
    .replace(/[.,!?;:'"]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim()
}

function extractNumber(text: string): number | null {
  // Try numeric first
  const numMatch = text.match(/\d+/)
  if (numMatch) {
    return parseInt(numMatch[0])
  }
  
  // Try Malay words
  const normalizedText = normalizeText(text)
  for (const [word, value] of Object.entries(MALAY_NUMBERS)) {
    if (normalizedText.includes(word)) {
      return value
    }
  }
  
  return null
}

function findMenuItem(text: string, menuItems: MenuItem[]): MenuItem | null {
  const normalizedText = normalizeText(text)
  
  for (const item of menuItems) {
    const itemName = normalizeText(item.name)
    
    // Direct match
    if (normalizedText.includes(itemName)) {
      return item
    }
    
    // Alias match
    if (item.aliases) {
      for (const alias of item.aliases) {
        if (normalizedText.includes(normalizeText(alias))) {
          return item
        }
      }
    }
    
    // Partial word match (for compound item names)
    const itemWords = itemName.split(' ').filter(w => w.length > 2)
    const textWords = normalizedText.split(' ')
    const matchCount = itemWords.filter(iw => textWords.some(tw => tw.includes(iw) || iw.includes(tw))).length
    if (matchCount >= Math.ceil(itemWords.length * 0.7)) {
      return item
    }
  }
  
  return null
}

function parseTranscript(transcript: string, menuItems: MenuItem[]): { items: ParsedItem[], cash: ParsedCash | null } {
  const normalizedTranscript = normalizeText(transcript)
  const parsedItems: ParsedItem[] = []
  const processedItemIds = new Set<string>()
  
  // Split into segments (by comma, period, "dan", "and", "then")
  const segments = normalizedTranscript.split(/[,.]|\b(dan|and|then|lepas tu|kemudian)\b/)
    .filter(s => s && s.trim().length > 0)
  
  for (const segment of segments) {
    const trimmedSegment = segment.trim()
    if (!trimmedSegment) continue
    
    // Find menu item in this segment
    const menuItem = findMenuItem(trimmedSegment, menuItems)
    if (!menuItem) continue
    
    // Skip if already processed (avoid duplicates)
    if (processedItemIds.has(menuItem.id)) continue
    processedItemIds.add(menuItem.id)
    
    // Extract quantity
    let quantity = extractNumber(trimmedSegment) || 1
    
    // Check for sold out
    const soldOut = SOLD_OUT_INDICATORS.some(ind => trimmedSegment.includes(ind))
    
    // Calculate confidence based on match quality
    const itemNameLower = normalizeText(menuItem.name)
    const isExactMatch = trimmedSegment.includes(itemNameLower)
    const confidence = isExactMatch ? 0.95 : 0.75
    
    parsedItems.push({
      menuItemId: menuItem.id,
      menuItemName: menuItem.name,
      quantity,
      soldOut,
      confidence,
      matchedText: trimmedSegment,
    })
  }
  
  // Parse cash amount
  let cashResult: ParsedCash | null = null
  const hasCashIndicator = CASH_INDICATORS.some(ind => normalizedTranscript.includes(ind))
  
  if (hasCashIndicator) {
    // Look for cash amounts (numbers followed by ringgit/rm or large numbers)
    const cashMatches = normalizedTranscript.matchAll(/(\d+(?:\.\d{2})?)\s*(?:ringgit|rm)?/g)
    
    for (const match of cashMatches) {
      const amount = parseFloat(match[1])
      // Consider it cash if it's a reasonable total (> RM10)
      if (amount >= 10) {
        const isApproximate = APPROXIMATE_INDICATORS.some(ind => 
          normalizedTranscript.includes(ind)
        )
        
        cashResult = {
          amount,
          isApproximate,
          matchedText: match[0],
        }
        break
      }
    }
  }
  
  return { items: parsedItems, cash: cashResult }
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    // Get auth header for user verification
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      throw new Error('Missing authorization header')
    }

    // Parse request
    const { transcript, menuItems, language = 'ms' }: ParseRequest = await req.json()
    
    if (!transcript) {
      throw new Error('transcript is required')
    }
    
    if (!menuItems || menuItems.length === 0) {
      throw new Error('menuItems array is required')
    }

    console.log(`Parsing transcript: "${transcript.substring(0, 100)}..." against ${menuItems.length} menu items`)

    // Parse the transcript
    const { items, cash } = parseTranscript(transcript, menuItems)

    console.log(`Parsed ${items.length} items, cash: ${cash?.amount || 'none'}`)

    const response: ParseResponse = {
      success: true,
      items,
      cash: cash || undefined,
    }

    return new Response(JSON.stringify(response), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })

  } catch (error) {
    console.error('Parse error:', error)
    
    const response: ParseResponse = {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error occurred',
    }

    return new Response(JSON.stringify(response), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
