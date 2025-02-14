#!/bin/bash

# SKK-JISYOをutf-8に変換するスクリプト。
# 引数で与えられたSKK-JISYOをUTF-8に変換して"<元のファイル名>.utf-8"と
# して出力する。
# euc-jpなファイルにしか(iconvが)対応していない。

for filename in $@; do
    # ファイル名が".utf8"で無い"SKK-JISYO*"なら処理
    if [[ ${filename} =~ .*SKK-JISYO.* ]] && \
           [ ${filename##*.} != "utf8" ]; then

        # 入力ファイルの文字コードを取得
        from_code=$(head -n 1 ${filename} | \
                        sed -r '1s/^.*coding: (euc-\w+).*/\1/')

        # form_codeがeuc-jpなら、1行目のコメントを修正した後、iconvで変換
        # euc-jisを変換する上手い方法を思い付いたら改造する予定
        if [ ${from_code} = "euc-jp" ]; then
            sed -e "1s/${from_code}/utf-8/" ${filename} | \
                iconv -f ${from_code} -t utf-8 > ${filename}.utf8
        fi
    fi
done
