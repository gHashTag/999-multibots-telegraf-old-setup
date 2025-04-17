import { VideoModel } from '@/interfaces'

export interface VideoModelConfig {
  name: VideoModel
  title: string
  description: string
}

export const VIDEO_MODELS: VideoModelConfig[] = [
  {
    name: 'minimax',
    title: 'Minimax',
    description: 'Оптимальное качество и скорость',
  },
  {
    name: 'haiper',
    title: 'Haiper',
    description: 'Высокое качество, длительность 6 секунд',
  },
  {
    name: 'ray',
    title: 'Ray',
    description: 'Реалистичная анимация',
  },
  {
    name: 'i2vgen-xl',
    title: 'I2VGen-XL',
    description: 'Продвинутая модель для детальной анимации',
  },
]

export type Mode =
  | 'subscribe'
  | 'digital_avatar_body'
  | 'digital_avatar_body_2'
  | 'neuro_photo'
  | 'neuro_photo_2'
  | 'image_to_prompt'
  | 'avatar_brain'
  | 'chat_with_avatar'
  | 'image_to_video'
  | 'text_to_speech'
  | 'text_to_image'
  | 'text_to_video'
  | 'voice'
  | 'select_model'
  | 'invite'
  | 'help'
  | 'start_learning'
  | 'top_up_balance'
  | 'balance'
  | 'main_menu'
  | 'improve_prompt'
  | 'change_size'
  | 'lip_sync'
  | 'getRuBill'
  | 'getEmailWizard'
  | 'price'
  | 'video_in_url'

export type ModeCosts = Required<Record<Mode, number>>
