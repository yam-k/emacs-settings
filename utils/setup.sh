#!/bin/sh
# ホームディレクトリに設定ファイルのシンボリックリンクを貼る。

# "|"の前が、sources/からの設定ファイルへの相対パス。
# "|"の後が、作成するシンボリックリンクの$HOMEからの相対パス。
sources=(
    "emacs.d|.emacs.d"
    "Xresources|.Xresources"
    "xinitrc|.xinitrc"
)
sources_dir=$(cd $(dirname $0)/../sources; pwd)

for source in ${sources[@]}; do
    source_file=${sources_dir}/${source%|*}
    target_file=${HOME}/${source#*|}

    # 古いファイルを削除するか確認する。
    if [ -L ${target_file} ] || [ -f ${target_file} ]; then
        echo "${target_file} already exists. Delete old setting? (yes/no)"
        read answer

        if [ -z ${answer} ] || [ ${answer} != "yes" ]; then
            continue
        else
            rm -f ${target_file}
        fi
    elif [ -d ${target_file} ]; then
        echo "${target_file} is directory. Delete this and make symlink? (yes/no)"
        read answer

        if [ -z ${answer} ] || [ ${answer} != "yes" ]; then
            continue
        else
            rm -rf ${target_file}
        fi
    fi

    # シンボリックリンクを作成。
    echo "Making symbolic link ${target_file} to ${source_file}"
    ln -s -f ${source_file} ${target_file}
    echo "Done."
done
