import { MyWizardContext } from '@/interfaces'
import { levels } from '@/menu/mainMenu'
import { isRussian } from '@/helpers/language'
import { priceCommand } from '@/commands/priceCommand'

// Функция, которая обрабатывает логику сцены
export const handleMenu = async (ctx: MyWizardContext) => {
  console.log('CASE: handleMenuCommand')
  const isRu = isRussian(ctx)
  if (ctx.message && 'text' in ctx.message) {
    const text = ctx.message.text || ''
    console.log('CASE: handleMenuCommand.text', text)

    // Создаем объект для сопоставления текста с действиями
    const actions = {
      [isRu ? levels[0].title_ru : levels[0].title_en]: async () => {
        console.log('CASE: 💫 Оформление подписки')
        ctx.session.mode = 'subscribe'
        await ctx.scene.enter('subscriptionScene')
      },
      [isRu ? levels[1].title_ru : levels[1].title_en]: async () => {
        console.log('CASE: 🤖 Цифровое тело')
        ctx.session.mode = 'digital_avatar_body'
        await ctx.scene.enter('checkBalanceScene')
      },
      [isRu ? '🤖 Цифровое тело 2' : '🤖 Digital Body 2']: async () => {
        console.log('CASE: 🤖 Цифровое тело 2')
        ctx.session.mode = 'digital_avatar_body_2'
        await ctx.scene.enter('checkBalanceScene')
      },
      [isRu ? levels[2].title_ru : levels[2].title_en]: async () => {
        console.log('CASE handleMenu: 📸 Нейрофото')
        ctx.session.mode = 'neuro_photo'
        await ctx.scene.enter('checkBalanceScene')
      },
      [isRu ? '📸 Нейрофото 2' : '📸 NeuroPhoto 2']: async () => {
        console.log('CASE: 📸 Нейрофото 2')
        ctx.session.mode = 'neuro_photo_2'
        await ctx.scene.enter('checkBalanceScene')
      },
      [isRu ? levels[3].title_ru : levels[3].title_en]: async () => {
        console.log('CASE: 🔍 Промпт из фото')
        ctx.session.mode = 'image_to_prompt'
        await ctx.scene.enter('checkBalanceScene')
      },
      [isRu ? levels[4].title_ru : levels[4].title_en]: async () => {
        console.log('CASE: 🧠 Мозг аватара')
        ctx.session.mode = 'avatar_brain'
        await ctx.scene.enter('checkBalanceScene')
      },
      [isRu ? levels[5].title_ru : levels[5].title_en]: async () => {
        console.log('CASE: 💭 Чат с аватаром')
        ctx.session.mode = 'chat_with_avatar'
        await ctx.scene.enter('checkBalanceScene')
      },
      [isRu ? levels[6].title_ru : levels[6].title_en]: async () => {
        console.log('CASE: 🤖 Выбор модели ИИ')
        ctx.session.mode = 'select_model'
        await ctx.scene.enter('checkBalanceScene')
      },
      [isRu ? levels[7].title_ru : levels[7].title_en]: async () => {
        console.log('CASE: 🎤 Голос аватара')
        ctx.session.mode = 'voice'
        await ctx.scene.enter('checkBalanceScene')
      },
      [isRu ? levels[8].title_ru : levels[8].title_en]: async () => {
        console.log('CASE: 🎙️ Текст в голос')
        ctx.session.mode = 'text_to_speech'
        await ctx.scene.enter('checkBalanceScene')
      },
      [isRu ? levels[9].title_ru : levels[9].title_en]: async () => {
        console.log('CASE: 🎥 Фото в видео')
        ctx.session.mode = 'image_to_video'
        await ctx.scene.enter('checkBalanceScene')
      },
      [isRu ? levels[10].title_ru : levels[10].title_en]: async () => {
        console.log('CASE:  Видео из текста')
        ctx.session.mode = 'text_to_video'
        await ctx.scene.enter('checkBalanceScene')
      },
      [isRu ? levels[11].title_ru : levels[11].title_en]: async () => {
        console.log('CASE: 🖼️ Текст в фото')
        ctx.session.mode = 'text_to_image'
        await ctx.scene.enter('checkBalanceScene')
      },
      // [isRu ? levels[12].title_ru : levels[12].title_en]: async () => {
      //   console.log('CASE: 🎤 Синхронизация губ')
      //   ctx.session.mode = 'lip_sync'
      //   await ctx.scene.enter('checkBalanceScene')
      // },
      // [isRu ? levels[13].title_ru : levels[13].title_en]: async () => {
      //   console.log('CASE: 🎥 Видео в URL')
      //   ctx.session.mode = 'video_in_url'
      //   await ctx.scene.enter('checkBalanceScene')
      // },
      [isRu ? levels[100].title_ru : levels[100].title_en]: async () => {
        console.log('CASE: 💎 Пополнить баланс')
        ctx.session.mode = 'top_up_balance'
        await ctx.scene.enter('paymentScene')
      },
      [isRu ? levels[101].title_ru : levels[101].title_en]: async () => {
        console.log('CASE: 🤑 Баланс')
        ctx.session.mode = 'balance'
        await ctx.scene.enter('balanceScene')
      },
      [isRu ? levels[102].title_ru : levels[102].title_en]: async () => {
        console.log('CASE: 👥 Пригласить друга')
        ctx.session.mode = 'invite'
        await ctx.scene.enter('inviteScene')
      },
      [isRu ? levels[103].title_ru : levels[103].title_en]: async () => {
        console.log('CASE: ❓ Помощь')
        ctx.session.mode = 'help'
        await ctx.scene.enter('helpScene')
      },
      [isRu ? levels[104].title_ru : levels[104].title_en]: async () => {
        console.log('CASE: 🏠 Главное меню')
        ctx.session.mode = 'main_menu'
        await ctx.scene.enter('menuScene')
      },
      '/invite': async () => {
        console.log('CASE: 👥 Пригласить друга')
        ctx.session.mode = 'invite'
        await ctx.scene.enter('inviteScene')
      },
      '/price': async () => {
        console.log('CASE: 💰 Цена')
        ctx.session.mode = 'price'
        await priceCommand(ctx)
      },
      '/buy': async () => {
        console.log('CASE: 💰 Пополнить баланс')
        ctx.session.mode = 'top_up_balance'
        await ctx.scene.enter('paymentScene')
      },
      '/balance': async () => {
        console.log('CASE: 💰 Баланс')
        ctx.session.mode = 'balance'
        await ctx.scene.enter('balanceScene')
      },
      '/help': async () => {
        console.log('CASE: ❓ Помощь')
        ctx.session.mode = 'help'
        await ctx.scene.enter('helpScene')
      },
      '/menu': async () => {
        console.log('CASE: 🏠 Главное меню')
        ctx.session.mode = 'main_menu'
        await ctx.scene.enter('menuScene')
      },
      '/start': async () => {
        console.log('CASE: 🚀 Начать обучение')

        await ctx.scene.enter('startScene')
      },
    }

    // Выполняем действие, если оно существует, иначе переходим в главное меню
    if (actions[text]) {
      console.log('CASE: handleMenuCommand.if', text)
      await actions[text]()
    } else {
      console.log('CASE: handleMenuCommand.else', text)
      // ctx.session.mode = 'main_menu'
      // await ctx.scene.enter('menuScene')
    }
  }
}

// Экспортируем функцию, если она будет использоваться в другом месте
export default handleMenu
