# Chapter 1 LEXING

## Token.zig

作者原本使用 string 來定義 TokenType 這裡我使用 *enum* 來定義
另外新增一個 *init* function 來建立此物件
並且新增一個 *format* function 以便輸出列印
keywords 資料儲存方式使用 tuple (anonymous structure) 原作者是使用 map[string]TokenType

## Lexer.zig

use tuple (anonymous structure without field name) to create test pattern to test *nextToken* function
使用 Token.init() 來取代原著的 newToken()
nextToken() function 使用 destructuring tuples 來回傳多個結果
新增 *iterator* function 來讓 REPL 能夠讀取 token 並且顯示出來

## Repl.zig

利用 Lexer 的 iterator() 來顯示 token

# Chapter 2 PARSING
