#TextMate2IMFix

TextMate 2 の日本語入力を改善する tmplugin です。変換確定時の return など一応ちゃんと機能するようになります。

/Users/~/Library/Application Support/TextMate/PlugIns
に入れて使ってください。TextMate 1 では読み込まないようにしています。バージョンを調べて 9147 ビルド以降で読み込むようにしています。

Downloads セクションにバイナリを置いておきます。

現在 TextMate 2 では com.macromates. で始まる CFBundleIdentifier を持つ tmplugin しか読み込まないようなので、com.macromates.com.hetima.TextMate2IMFix という変則的な CFBundleIdentifier にしています。

#License

未定。TextMate 2 のソースを直接使ってはいないけれど、参考にはしたので GPL3 にした方が良いのかな。