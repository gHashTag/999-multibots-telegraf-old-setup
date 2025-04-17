import axios, { isAxiosError } from 'axios'
import { isDev, SECRET_API_KEY, ELESTIO_URL, LOCAL_SERVER_URL } from '@/config'
import { MyContext } from '@/interfaces'
import { sendGenericErrorMessage } from '@/menu'

interface VoiceAvatarResponse {
  success: boolean
  message: string
}

export async function generateVoiceAvatar(
  fileUrl: string,
  telegram_id: string,
  ctx: MyContext,
  isRu: boolean,
  botName: string
): Promise<VoiceAvatarResponse> {
  try {
    const url = `${
      isDev ? LOCAL_SERVER_URL : ELESTIO_URL
    }/generate/create-avatar-voice`

    const response = await axios.post<VoiceAvatarResponse>(
      url,
      {
        fileUrl,
        telegram_id,
        username: ctx.from?.username,
        is_ru: isRu,
        bot_name: botName,
      },
      {
        headers: {
          'Content-Type': 'application/json',
          'x-secret-key': SECRET_API_KEY,
        },
      }
    )

    console.log('Voice avatar creation response:', response.data)
    return response.data
  } catch (error) {
    if (isAxiosError(error)) {
      console.error('API Error:', error.response?.data || error.message)
      await sendGenericErrorMessage(ctx, isRu, error)
    }
    console.error('Unexpected error:', error)
    throw error
  }
}
