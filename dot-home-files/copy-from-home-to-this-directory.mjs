import { copyFile } from 'node:fs/promises'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'
import process from 'node:process'

const __dirname = dirname(fileURLToPath(import.meta.url))
const homeDir = process.env.HOME

await copyFile(join(homeDir, '/.zshrc'), join(__dirname, '/.zshrc'))
console.log('.zshrc copied to home directory')

await copyFile(join(homeDir, '/.gitconfig'), join(__dirname, './.gitconfig'))
console.log('.gitconfig copied to home directory')

await copyFile(join(homeDir, '/.tmux.conf'), (__dirname, './.tmux.conf'))
console.log('.tmux.conf copied to home directory')
