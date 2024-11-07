import { copyFile } from 'node:fs/promises'
import { dirname, join } from 'node:path'
import { fileURLToPath } from 'node:url'

const __dirname = dirname(fileURLToPath(import.meta.url))

await copyFile(join(__dirname, '.zshrc'), join(__dirname, '~/.zshrc'))
console.log('.zshrc copied to home directory')

await copyFile(join(__dirname, '.gitconfig'), join(__dirname, '~/.gitconfig'))
console.log('.gitconfig copied to home directory')

await copyFile(join(__dirname, '.tmux.conf'), join(__dirname, '~/.tmux.conf'))
console.log('.tmux.conf copied to home directory')
