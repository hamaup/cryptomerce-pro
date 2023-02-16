## Slash Web3 Payment実装

Railsで作成したweb2　越境ECサービスにSlash Web3 paymentsを実装します。

Slash
https://slash.fi/
次世代の分散型決済サービスです。

Slash Project White Paper
https://slash-fi.gitbook.io/docs/whitepaper/slash-project-white-paper

### 概要
Slash Web3 payments ボタンをお会計（チェックアウト）画面に配置しました。
決済が開始されると決済ステータス変更、オーダー情報作成します。
Slash Web3 paymentsから返ってくる結果に基づいて、決済成功もしくは失敗を判断し、注文履歴を確認できます。

### ステータスコード
決済処理中: ステータスを決済中 (processing_payment)
決済失敗: ステータスを決済失敗（failure_payment）
決済成功: ステータスを決済済み（confirm_payment)

決済が進展しない場合は、15分後にcron処理を使用してステータスを決済中 (processing_payment)から
ステータスを決済失敗（failure_payment)します。これにより、永久に在庫を持つ状態を防ぎます。

### Payment Request API
決済開始前に テストネットのポータルに記載がある identification_token, verify_token と order_code を作成して
Payment Request APIを呼び出すと、Payment Tokenが返ってきます。
https://testnet.slash.fi/admin/dashboard

「Slash Web3 payments」ボタンをクリックすると、Payment Tokenが付与されたURLにアクセスすると
決済画面に切り替わり簡単にスムーズに決済を開始させることができます。
モバイル版はSlash Paymentの画面は別タブで開きます。

### Payment Result API
ECサイト側に、Slashから決済処理結果を受け取る（kickback）Payment Result APIを作成します。
テストネットのポータルに、そのAPIのURLをkickback用URLを記入するとSlashから決済結果が通知されるようになるので、
決済が成功したか失敗したか判断できます。

### モバイル版の対応
metamaskなどのウォレットアプリから元のECサイトの画面に戻る必要がありますが、決済完了後、決済処理結果通知を受け取り処理で
決済結果画面へリダイレクトしているので、ECサイトの画面に戻ると自動的に決済結果画面になります。
もし決済画面になっていない場合でも、再度Slash Web3 payments ボタンをクリックすると決済結果画面になります。

### デモ

#### PC

https://user-images.githubusercontent.com/32893785/219312005-0c138ca6-35d4-46dd-b8b7-1ebf8d9323dc.mov

#### モバイル

https://user-images.githubusercontent.com/32893785/219312448-d53a44a3-039b-4284-8372-67937a1b46f0.mov


### Thank for
https://github.com/FarStep131/docker-rails-example
https://github.com/nickjj/docker-rails-example/






