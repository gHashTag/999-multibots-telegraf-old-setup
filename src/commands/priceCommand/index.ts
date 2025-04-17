import { starCost } from '@/price'
import { MyContext } from '../../interfaces'
import { minCost, maxCost } from '@/scenes/checkBalanceScene'
import { modeCosts } from '@/scenes/checkBalanceScene'
import { conversionRates } from '@/price/priceCalculator'

export async function priceCommand(ctx: MyContext) {
  console.log('CASE: priceCommand')
  const isRu = ctx.from?.language_code === 'ru'

  const message = isRu
    ? `
    <b>💰 Стоимость всех услуг:</b>
    - 🧠 Обучение модели за 1 шаг: ${conversionRates.costPerStepInStars.toFixed(
      2
    )} ⭐️
    - ✍️ Генерация промпта: ${modeCosts.text_to_image.toFixed(2)} ⭐️
    - 🖼️ Генерация изображения: от ${minCost.toFixed(2)} до ${maxCost.toFixed(
        2
      )} ⭐️
    - 🤖 Нейро-генерация изображения: ${modeCosts.image_to_prompt.toFixed(
      2
    )} ⭐️
    - 🎥 Текст в видео: ${modeCosts.text_to_video.toFixed(2)} ⭐️
    - 🎤 Голос: ${modeCosts.voice.toFixed(2)} ⭐️
    - 🗣️ Текст в речь: ${modeCosts.text_to_speech.toFixed(2)} ⭐️
    - 📽️ Изображение в видео: ${modeCosts.image_to_video.toFixed(2)} ⭐️

    <b>💵 Стоимость звезды:</b> ${(starCost * 99).toFixed(2)} руб
    💵 Пополнение баланса /buy
    `
    : `
    <b>💰 Price of all services:</b>
    - 🧠 Training model: ${conversionRates.costPerStepInStars.toFixed(2)} ⭐️
    - ✍️ Prompt generation: ${modeCosts.text_to_image.toFixed(2)} ⭐️
    - 🖼️ Image generation: from ${minCost.toFixed(2)} to ${maxCost.toFixed(
        2
      )} ⭐️
    - 🤖 Neuro-image generation: ${modeCosts.image_to_prompt.toFixed(2)} ⭐️
    - 🎥 Text to video: ${modeCosts.text_to_video.toFixed(2)} ⭐️
    - 🎤 Voice: ${modeCosts.voice.toFixed(2)} ⭐️
    - 🗣️ Text to speech: ${modeCosts.text_to_speech.toFixed(2)} ⭐️
    - 📽️ Image to video: ${modeCosts.image_to_video.toFixed(2)} ⭐️

    <b>💵 Star cost:</b> ${starCost.toFixed(2)} $
    💵 Top up balance /buy
    `
  //
  await ctx.reply(message, { parse_mode: 'HTML' })
}
