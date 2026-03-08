// Supabase Edge Function: Speech-to-Text via OpenAI Whisper API
// Proxies audio transcription requests to OpenAI while keeping API key secure

import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

interface TranscriptionRequest {
  audioPath: string // Path in Supabase Storage
  language?: string // 'ms' for Malay, 'en' for English
}

interface TranscriptionResponse {
  success: boolean
  transcript?: string
  confidence?: number
  language?: string
  duration?: number
  error?: string
}

serve(async (req) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const openaiApiKey = Deno.env.get('OPENAI_API_KEY')
    if (!openaiApiKey) {
      throw new Error('OPENAI_API_KEY not configured')
    }

    const supabaseUrl = Deno.env.get('SUPABASE_URL')!
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    
    // Get auth header for user verification
    const authHeader = req.headers.get('Authorization')
    if (!authHeader) {
      throw new Error('Missing authorization header')
    }

    // Create Supabase client
    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Parse request
    const { audioPath, language = 'ms' }: TranscriptionRequest = await req.json()
    
    if (!audioPath) {
      throw new Error('audioPath is required')
    }

    console.log(`Transcribing audio: ${audioPath}, language: ${language}`)

    // Download audio from Supabase Storage
    const { data: audioData, error: downloadError } = await supabase
      .storage
      .from('evidence')
      .download(audioPath)

    if (downloadError || !audioData) {
      throw new Error(`Failed to download audio: ${downloadError?.message || 'Unknown error'}`)
    }

    // Prepare form data for OpenAI Whisper API
    const formData = new FormData()
    formData.append('file', audioData, 'audio.m4a')
    formData.append('model', 'whisper-1')
    formData.append('language', language)
    formData.append('response_format', 'verbose_json')
    
    // Add prompt to improve Malay transcription accuracy
    if (language === 'ms') {
      formData.append('prompt', 'Ini adalah rakaman jualan gerai makanan Malaysia. Contoh: nasi lemak, mee goreng, teh tarik, roti canai, char kuey teow, laksa.')
    }

    // Call OpenAI Whisper API
    const whisperResponse = await fetch('https://api.openai.com/v1/audio/transcriptions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${openaiApiKey}`,
      },
      body: formData,
    })

    if (!whisperResponse.ok) {
      const errorText = await whisperResponse.text()
      throw new Error(`Whisper API error: ${whisperResponse.status} - ${errorText}`)
    }

    const whisperResult = await whisperResponse.json()

    // Extract results
    const transcript = whisperResult.text || ''
    const duration = whisperResult.duration || 0
    
    // Calculate confidence from average segment confidence (if available)
    let confidence = 0.85 // Default confidence
    if (whisperResult.segments && whisperResult.segments.length > 0) {
      const avgLogProb = whisperResult.segments.reduce(
        (sum: number, seg: any) => sum + (seg.avg_logprob || 0), 0
      ) / whisperResult.segments.length
      // Convert log probability to confidence (rough approximation)
      confidence = Math.min(0.99, Math.max(0.5, 1 + avgLogProb / 5))
    }

    console.log(`Transcription complete: ${transcript.substring(0, 100)}...`)

    const response: TranscriptionResponse = {
      success: true,
      transcript,
      confidence,
      language: whisperResult.language || language,
      duration,
    }

    return new Response(JSON.stringify(response), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })

  } catch (error) {
    console.error('Transcription error:', error)
    
    const response: TranscriptionResponse = {
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error occurred',
    }

    return new Response(JSON.stringify(response), {
      status: 400,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})
