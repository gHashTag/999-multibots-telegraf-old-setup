import { Telegraf } from 'telegraf'
import { MyContext } from '@/interfaces'

const production = async (
  bot: Telegraf<MyContext>,
  port: number,
  webhookUrl: string,
  path: string
): Promise<void> => {
  try {
    await bot.telegram.deleteWebhook({ drop_pending_updates: true })
    console.log('Old webhook deleted')

    await new Promise(resolve => setTimeout(resolve, 2000))

    bot.launch({
      webhook: {
        domain: webhookUrl,
        port,
        path,
        secretToken: process.env.SECRET_TOKEN,
      },
    })
    return
  } catch (e) {
    console.error('Error in production setup:', e)
    throw e
  }
}

const development = async (bot: Telegraf<MyContext>): Promise<void> => {
  try {
    await bot.telegram.deleteWebhook({ drop_pending_updates: true })
    console.log('[SERVER] Webhook deleted, starting polling...')
    await new Promise(resolve => setTimeout(resolve, 1000))

    bot.launch()
    return
  } catch (e) {
    console.error('Error in development setup:', e)
    throw e
  }
}

export { production, development }
