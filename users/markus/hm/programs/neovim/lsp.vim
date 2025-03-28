let g:LanguageClient_serverCommands = { 'haskell': ['haskell-language-server', '--lsp', '--logfile', '/tmp/hls.log', '--debug'] }
let g:LanguageClient_rootMarkers = ['*.cabal', 'stack.yaml']
let g:LanguageClient_settingsPath = "~/.config/nvim/settings.json"
let g:LanguageClient_loggingFile = "/tmp/nvim-language-client.log"
let g:LanguageClient_loggingLevel = "DEBUG"

nnoremap <F5> :call LanguageClient_contextMenu()<CR>
map <Leader>lk :call LanguageClient#textDocument_hover()<CR>
map <Leader>lg :call LanguageClient#textDocument_definition()<CR>
map <Leader>lr :call LanguageClient#textDocument_rename()<CR>
map <Leader>lf :call LanguageClient#textDocument_formatting()<CR>
map <Leader>lb :call LanguageClient#textDocument_references()<CR>
map <Leader>la :call LanguageClient#textDocument_codeAction()<CR>
map <Leader>ls :call LanguageClient#textDocument_documentSymbol()<CR>
