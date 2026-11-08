# ~/.zsh/conf/ca-check.sh — 漏洩した eMudhra 系ルート CA の残存チェックと対処
#
# 行頭が "#:" の行はヘルプ文書（Markdown）。`ca-check-help` で表示する（bat があれば整形表示）。
# このファイルは ~/.zshrc から読み込まれ、関数を定義するだけで何も実行しない。
#
#: # ca-check — 漏洩した eMudhra 系ルート CA の残存チェックと対処
#:
#: ## 背景（2026-10）
#:
#: - eMudhra の TLS 用中間 CA の秘密鍵が漏洩した。
#:   Apple の記事: https://support.apple.com/en-us/149555
#: - Apple は 2026-10-19 から、Safari・Mail・Apple のネットワーク機能を使うアプリで該当の中間 CA を自動でブロックしている。
#: - ただし、**自前の証明書バンドル（PEM ファイル）や内蔵リストで検証するツールにはこのブロックが効かない**。
#:   curl / git / openssl / Homebrew / Nix / uv / Bun / colima の VM などが該当する。
#: - 対処は、各バンドルから次の2本のルートを外すこと。
#:   - **emSign ECC Root CA - G3**（eMudhra 本体のルート）
#:   - **AAA Certificate Services**（Sectigo が相互署名した中間 CA の経由先。外すかどうかは任意）
#:
#: ## 使い方
#:
#: | コマンド | 何をするか | sudo |
#: |---|---|---|
#: | `ca-check [追加ディレクトリ...]` | 残っている場所を調べ、結果の読み方と次にやることを表示する | 不要 |
#: | `ca-fix` | sudo の要らない対処（Homebrew のバンドル）を実行する | 不要 |
#: | `ca-strip-filter < 入力 > 出力` | PEM バンドルから2本を除いたものを出力する（部品） | 不要 |
#: | `ca-check-help` | この文書を表示する | 不要 |
#:
#: - **基本の流れ:** `ca-check` → 表示された順に対処 → もう一度 `ca-check` で全項目が ✅ になれば完了。
#: - `ca-check ~/Codes` のようにディレクトリを渡すと、その下の `*.pem` / `*.crt` も調べる（数十秒かかることがある）。
#: - colima の VM の確認は `colima ssh` で読み取りだけを行う。飛ばしたいときは `CA_CHECK_SKIP_COLIMA=1 ca-check`。
#: - sudo と colima の VM 内での作業は、関数からは実行しない。表示されたコマンドを自分のターミナルにコピペして実行する。
#:
#: ## 結果の読み方
#:
#: - ✅ 対処済み（または問題のルートを持っていない）
#: - ❌ 問題のルートが残っている。「次にやること」の該当ブロックを実行する
#: - ⏳ 設定では直せない。ツール側の更新を待つ（ca-check で定期的に確認）
#: - ℹ️ 参考。普段の使い方では実害がないか、この Mac の外の話（アプリ同梱など）
#:
#: 「次にやること」は区分ごとに分かれている。上から順に実行すればよい。
#:
#: 1. **このシェルで実行（sudo 不要）** — `ca-fix` を実行する
#: 2. **sudo が必要** — 表示されたコマンドをコピペして実行する（パスワードを聞かれる）
#: 3. **colima の VM 内で実行** — `colima ssh` で VM に入ってから実行する
#:
#: ## 主な対象と、元に戻ってしまうタイミング
#:
#: | 対象 | ファイル | 区分 | 元に戻るタイミング |
#: |---|---|---|---|
#: | macOS 標準の curl / git / openssl / ruby / python3 | `/etc/ssl/cert.pem` | sudo | macOS のアップデート |
#: | Homebrew（brew の python3・openssl@3 も含む） | `$(brew --prefix)/etc/ca-certificates/cert.pem` | sudo 不要 | `brew upgrade` で ca-certificates が更新されたとき |
#: | Nix daemon（Determinate 版） | `nix.conf` の `ssl-cert-file`（例: `/etc/nix/macos-keychain.crt`） | sudo | Mac の再起動や Nix の更新（キーチェーンから作り直される） |
#: | Nix で入れたツール | `NIX_SSL_CERT_FILE`（`~/.zshenv` で Homebrew のバンドルに向けている） | 設定のみ | 戻らない |
#: | uv | 内蔵リスト。`UV_SYSTEM_CERTS=1`（`~/.zshenv`）で OS の信頼ストアに切り替え | 設定のみ | 戻らない |
#: | Bun | 内蔵リスト。オプション・環境変数では外せない（1.4.2 で検証済み） | 待つ | Bun の更新で解消 |
#: | colima の VM | VM 内の `/etc/ssl/certs/ca-certificates.crt` | VM 内で sudo | VM を作り直したとき |
#:
#: - Nix daemon の設定を `nix.custom.conf` に書いても効かない。
#:   Determinate 版の `nix.conf` は、`nix.custom.conf` を読み込む行が `ssl-cert-file` の行より前にあり、後の行が優先されるため。
#: - 全部を `/etc/ssl/cert.pem` に向ける方法は勧めない。Homebrew や Nix daemon のバンドルにはキーチェーン由来の証明書（社内 CA など）が入っていて、
#:   `/etc/ssl/cert.pem` には入っていないため、社内向けの通信が壊れることがある。
#:
#: ## 戻し方（何か壊れたとき）
#:
#: どのファイルも、初回の対処時に `<ファイル>.orig` としてバックアップしている。
#:
#: ```bash
#: cp -p "$(brew --prefix)/etc/ca-certificates/cert.pem.orig" "$(brew --prefix)/etc/ca-certificates/cert.pem"
#: sudo cp -p /etc/nix/macos-keychain.crt.orig /etc/nix/macos-keychain.crt
#: sudo cp -p /etc/ssl/cert.pem.orig /etc/ssl/cert.pem
#: ```
#:
#: - `~/.zshenv` は、追記した `UV_SYSTEM_CERTS` と `NIX_SSL_CERT_FILE` の行を消す（chezmoi で管理している）。
#: - colima の VM は、`/etc/ca-certificates.conf` の行頭に付けた `!` を消して `sudo update-ca-certificates --fresh` を実行する。
#: - `.orig` は初回にしか作らない。アップデートで元ファイルが新しくなったあとに古い `.orig` で戻すと、新しい内容が消えるので注意する。
#:
#: ## 仕組み
#:
#: - 証明書の名前ではなく、**証明書本体の base64 の1行（64文字）**で見分けている。
#:   バンドルごとに書式（見出しの有無など）が違っても、PEM の改行位置は共通なので同じ文字列で見つかる。
#: - 文字列は2本のルートの公開証明書から取った値で、秘密情報ではない。
#: - `ca-strip-filter` は、`-----BEGIN` から `-----END` までの1ブロックにこの文字列が含まれていれば、そのブロックを丸ごと除く。
#:
#: ## このファイルを消してよいとき
#:
#: Apple・Homebrew・Mozilla（certifi・nixpkgs・Bun）の更新が出そろって、`.orig` から戻しても `ca-check` が全部 ✅ になったら、
#: このファイルと `~/.zshenv` の2行は消してよい。

# 2本のルートの base64 本体の9行目（どの PEM バンドルでも同じ位置で折り返される）
typeset -g CA_CHECK_FRAG_EMSIGN='WXTsuwYc58Byr+iuL+FBVIcUqEqy6HyC5ltqtdyzdc6LBtCGI79G1Y4PPwT01xyS'
typeset -g CA_CHECK_FRAG_AAA='ADCCAQoCggEBAL5AnfRu4ep2hxxNRUSOvkbIgwadwSr+GB+O5AL686tdUIoWMQua'
typeset -g CA_CHECK_SELF=${${(%):-%x}:A}

# Markdown を表示する（bat があれば整形、無ければそのまま）
_ca_md() {
  if command -v bat >/dev/null 2>&1; then
    bat -l md -p --paging=never
  else
    cat
  fi
}

# ファイルに残っているルートの名前を "emSign AAA" の形で返す（無ければ空）
_ca_which() {
  local f=$1 r=()
  [[ -r $f ]] || return 0
  grep -q -F -e "$CA_CHECK_FRAG_EMSIGN" -- "$f" 2>/dev/null && r+=(emSign)
  grep -q -F -e "$CA_CHECK_FRAG_AAA" -- "$f" 2>/dev/null && r+=(AAA)
  print -r -- "${r[*]}"
}

# 標準入力の PEM バンドルから2本を除いて標準出力へ
ca-strip-filter() {
  awk -v f1="$CA_CHECK_FRAG_EMSIGN" -v f2="$CA_CHECK_FRAG_AAA" '
    /-----BEGIN /{inb=1; buf=""; bad=0}
    inb{buf=buf $0 "\n"; if(index($0,f1)||index($0,f2)) bad=1; if(/-----END /){inb=0; if(!bad) printf "%s",buf}; next}
    {print}'
}

ca-check-help() {
  sed -n 's/^#: \{0,1\}//p' "$CA_CHECK_SELF" | _ca_md
}

# Homebrew のバンドルの場所
_ca_brew_bundle() {
  local p=${HOMEBREW_PREFIX:-/opt/homebrew}
  print -r -- "$p/etc/ca-certificates/cert.pem"
}

# Nix daemon が使うバンドル（nix.conf で最後に書かれた ssl-cert-file）
_ca_nix_daemon_bundle() {
  [[ -r /etc/nix/nix.conf ]] || return 0
  sed -n 's/^[[:space:]]*ssl-cert-file[[:space:]]*=[[:space:]]*//p' /etc/nix/nix.conf | tail -1
}

# 状態の行を追加する: _ca_row <記号> <対象> <説明>
_ca_row() { rows+=("| $1 | $2 | $3 |"); }

ca-check() {
  emulate -L zsh
  local fence='```'
  local -a rows fix_user fix_sudo fix_vm waits infos
  local f hit

  # --- /etc/ssl/cert.pem（macOS 標準ツール） ---
  f=/etc/ssl/cert.pem
  hit=$(_ca_which $f)
  if [[ -z $hit ]]; then
    _ca_row ✅ "macOS 標準ツール" "\`$f\`"
  else
    _ca_row ❌ "macOS 標準ツール" "\`$f\` に残っている: $hit"
    fix_sudo+=("# macOS 標準の curl / git / openssl など（Apple の記事の手順）")
    fix_sudo+=("[ -e /etc/ssl/cert.pem.orig ] || sudo cp -p /etc/ssl/cert.pem /etc/ssl/cert.pem.orig")
    [[ $hit == *emSign* ]] && fix_sudo+=("t=\$(mktemp) && awk -v s='=== /C=IN/OU=emSign PKI/O=eMudhra Technologies Limited/CN=emSign ECC Root CA - G3' '/^(===|###) /{skip=0} \$0==s{skip=1} !skip' /etc/ssl/cert.pem > \"\$t\" && [ -s \"\$t\" ] && sudo install -m 0644 -o root -g wheel \"\$t\" /etc/ssl/cert.pem; rm -f \"\$t\"")
    [[ $hit == *AAA* ]] && fix_sudo+=("t=\$(mktemp) && awk -v s='=== /C=GB/ST=Greater Manchester/L=Salford/O=Comodo CA Limited/CN=AAA Certificate Services' '/^(===|###) /{skip=0} \$0==s{skip=1} !skip' /etc/ssl/cert.pem > \"\$t\" && [ -s \"\$t\" ] && sudo install -m 0644 -o root -g wheel \"\$t\" /etc/ssl/cert.pem; rm -f \"\$t\"")
    fix_sudo+=("")
  fi

  # --- Homebrew ---
  f=$(_ca_brew_bundle)
  if [[ -e $f ]]; then
    hit=$(_ca_which $f)
    if [[ -z $hit ]]; then
      _ca_row ✅ "Homebrew" "\`$f\`"
    else
      _ca_row ❌ "Homebrew" "\`$f\` に残っている: $hit"
      fix_user+=("Homebrew のバンドル（\`$f\`）")
    fi
  fi

  # --- Nix daemon ---
  f=$(_ca_nix_daemon_bundle)
  if [[ -n $f && -e $f ]]; then
    hit=$(_ca_which $f)
    if [[ -z $hit ]]; then
      _ca_row ✅ "Nix daemon" "\`$f\`"
    else
      _ca_row ❌ "Nix daemon" "\`$f\` に残っている: $hit（再起動などで作り直されると戻る）"
      fix_sudo+=("# Nix daemon（daemon の再起動は不要。ダウンロードのたびに読み込まれる）")
      fix_sudo+=("[ -e $f.orig ] || sudo cp -p $f $f.orig")
      fix_sudo+=("t=\$(mktemp) && ca-strip-filter < $f > \"\$t\" && [ -s \"\$t\" ] && sudo sh -c \"cat '\$t' > '$f'\"; rm -f \"\$t\"")
      fix_sudo+=("")
    fi
  fi

  # --- Nix で入れたツール（NIX_SSL_CERT_FILE） ---
  if [[ -d /nix ]]; then
    if [[ -z ${NIX_SSL_CERT_FILE:-} ]]; then
      _ca_row ℹ️ "Nix のツール" "\`NIX_SSL_CERT_FILE\` が未設定"
    else
      hit=$(_ca_which ${NIX_SSL_CERT_FILE:A})
      if [[ -z $hit ]]; then
        _ca_row ✅ "Nix のツール" "\`NIX_SSL_CERT_FILE=$NIX_SSL_CERT_FILE\`"
      else
        _ca_row ❌ "Nix のツール" "\`NIX_SSL_CERT_FILE\` の先に残っている: $hit"
        fix_user+=("\`~/.zshenv\` に \`export NIX_SSL_CERT_FILE=$(_ca_brew_bundle)\` を書く（Homebrew のバンドルを先に直すこと）")
      fi
    fi
  fi

  # --- uv ---
  if command -v uv >/dev/null 2>&1; then
    if [[ -n ${UV_SYSTEM_CERTS:-} ]]; then
      _ca_row ✅ "uv" "\`UV_SYSTEM_CERTS=$UV_SYSTEM_CERTS\`（OS の信頼ストアを使う）"
    else
      _ca_row ❌ "uv" "内蔵リストを使っている"
      fix_user+=("\`~/.zshenv\` に \`export UV_SYSTEM_CERTS=1\` を書く")
    fi
  fi

  # --- Bun ---
  if command -v bun >/dev/null 2>&1; then
    local bunres
    bunres=$(F1=$CA_CHECK_FRAG_EMSIGN F2=$CA_CHECK_FRAG_AAA bun -e "const r=require('tls').rootCertificates.map(c=>c.replace(/\s/g,''));const h=[];if(r.some(c=>c.includes(process.env.F1)))h.push('emSign');if(r.some(c=>c.includes(process.env.F2)))h.push('AAA');console.log(Bun.version+' '+h.join(' '))" </dev/null 2>/dev/null)
    if [[ -z $bunres ]]; then
      _ca_row ℹ️ "Bun" "確認できなかった"
    elif [[ $bunres == *' '?* ]]; then
      _ca_row ⏳ "Bun ${bunres%% *}" "内蔵リストに残っている: ${bunres#* }"
      waits+=("Bun: オプションや環境変数では内蔵リストから外せない。\`bun upgrade\` のあとに \`ca-check\` で確認する")
    else
      _ca_row ✅ "Bun ${bunres%% *}" "内蔵リストに入っていない"
    fi
  fi

  # --- python3 が読む証明書ファイル ---
  local p cafile
  for p in ${(u)$(whence -ap python3 2>/dev/null)}; do
    cafile=$($p -I -c 'import ssl;print(ssl.get_default_verify_paths().openssl_cafile)' </dev/null 2>/dev/null) || continue
    if [[ ! -e $cafile ]]; then
      infos+=("\`$p\`: 証明書ファイル \`$cafile\` が無い（HTTPS の検証自体が失敗する状態で、問題のルートは使われない。pip は OS の信頼ストアを使う）")
    else
      hit=$(_ca_which ${cafile:A})
      if [[ -n $hit ]]; then
        infos+=("\`$p\` は \`${cafile:A}\` を読む（$hit が残っている。上の該当するバンドルを直せば解消）")
      fi
    fi
  done

  # --- その他のバンドル（certifi・アプリ同梱など） ---
  local -a dirs=(/etc/ssl /etc/nix ${HOMEBREW_PREFIX:-/opt/homebrew}/etc ${HOMEBREW_PREFIX:-/opt/homebrew}/Cellar
                 /Library/Frameworks/Python.framework ~/.local ~/.bun ~/fvm ~/.pyenv ~/.rbenv ~/.nvm "$@")
  local -a existing=(${^dirs}(N/))
  local -a known=(/etc/ssl/cert.pem $(_ca_brew_bundle) $(_ca_nix_daemon_bundle))
  local -a found
  if (( ${#existing} )); then
    if command -v fd >/dev/null 2>&1; then
      found=(${(f)"$(fd -u -t f -e pem -e crt . $existing 2>/dev/null)"})
    else
      found=(${(f)"$(find $existing -type f \( -name '*.pem' -o -name '*.crt' \) 2>/dev/null)"})
    fi
  fi
  for f in $found; do
    (( ${known[(Ie)$f]} )) && continue
    hit=$(_ca_which $f)
    [[ -z $hit ]] && continue
    case $f in
      */pip/_vendor/certifi/cacert.pem)
        infos+=("\`$f\`（$hit）: pip 同梱の certifi。pip は普段 OS の信頼ストアを使うので実害は小さい") ;;
      */certifi/cacert.pem)
        infos+=("\`$f\`（$hit）: requests などが使う certifi。truststore を入れるか、certifi の更新を待つ") ;;
      *)
        infos+=("\`$f\`（$hit）: アプリやライブラリに同梱されたリスト。配布元の更新を待つ") ;;
    esac
  done

  # --- colima の VM（読み取りだけ） ---
  if [[ -z ${CA_CHECK_SKIP_COLIMA:-} ]] && command -v colima >/dev/null 2>&1; then
    if colima status >/dev/null 2>&1; then
      local vm
      vm=$(colima ssh -- grep -c -F -e "$CA_CHECK_FRAG_EMSIGN" -e "$CA_CHECK_FRAG_AAA" /etc/ssl/certs/ca-certificates.crt </dev/null 2>/dev/null)
      if [[ $vm == 0 ]]; then
        _ca_row ✅ "colima の VM" "\`/etc/ssl/certs/ca-certificates.crt\`"
      elif [[ -n $vm ]]; then
        _ca_row ❌ "colima の VM" "\`/etc/ssl/certs/ca-certificates.crt\` に ${vm} 本残っている"
        fix_vm+=("grep -nE 'emSign_ECC_Root_CA_-_G3|Comodo_AAA_Services_root' /etc/ca-certificates.conf")
        fix_vm+=("sudo sed -i -E 's#^(mozilla/(emSign_ECC_Root_CA_-_G3|Comodo_AAA_Services_root)\\.crt)#!\\1#' /etc/ca-certificates.conf")
        fix_vm+=("sudo update-ca-certificates --fresh && sudo systemctl restart docker")
        fix_vm+=("grep -nE 'emSign_ECC|Comodo_AAA' /etc/ca-certificates.conf   # 両方の行頭が ! なら成功")
        fix_vm+=("exit")
      else
        _ca_row ℹ️ "colima の VM" "確認できなかった"
      fi
    else
      _ca_row ℹ️ "colima の VM" "停止中のため確認していない（\`colima start\` のあとに再実行）"
    fi
  fi

  # --- 出力 ---
  {
    print -r -- "# ca-check の結果（$(date '+%Y-%m-%d %H:%M')）"
    print
    print -r -- "| 状態 | 対象 | 詳細 |"
    print -r -- "|---|---|---|"
    print -rl -- $rows
    print
    print -r -- "## 結果の読み方"
    print
    print -r -- "- ✅ 対処済み　❌ 残っている（下の「次にやること」を実行）　⏳ ツールの更新待ち　ℹ️ 参考"
    print -r -- "- 「次にやること」を上から順に実行し、最後にもう一度 \`ca-check\` を実行して ❌ が消えたことを確かめる。"
    print -r -- "- 背景・戻し方・仕組みは \`ca-check-help\` を参照。"
    print
    print -r -- "## 次にやること"
    print
    if (( ${#fix_user} + ${#fix_sudo} + ${#fix_vm} == 0 )); then
      print -r -- "対処が必要なものはありません。"
      print
    fi
    local n=1
    if (( ${#fix_user} )); then
      print -r -- "### $n. このシェルで実行（sudo 不要）"
      print
      print -rl -- "- "${^fix_user}
      print
      print -r -- "Homebrew のバンドルは次の1行で直る（\`.orig\` にバックアップを取る）。\`~/.zshenv\` の変更は手で書き、\`chezmoi re-add ~/.zshenv\` のあと chezmoi のリポジトリでコミットする。"
      print
      print -r -- "${fence}bash"
      print -r -- "ca-fix"
      print -r -- "$fence"
      print
      (( n++ ))
    fi
    if (( ${#fix_sudo} )); then
      print -r -- "### $n. sudo が必要（自分のターミナルにコピペして実行）"
      print
      print -r -- "${fence}bash"
      print -rl -- ${fix_sudo[1,-2]}
      print -r -- "$fence"
      print
      (( n++ ))
    fi
    if (( ${#fix_vm} )); then
      print -r -- "### $n. colima の VM 内で実行"
      print
      print -r -- "まず VM に入る（VM 内のシェルなので、シングルクォート内の \`!\` は zsh の履歴展開を受けない）。"
      print
      print -r -- "${fence}bash"
      print -r -- "colima ssh"
      print -r -- "$fence"
      print
      print -r -- "VM の中で次を順に実行する。"
      print
      print -r -- "${fence}bash"
      print -rl -- $fix_vm
      print -r -- "$fence"
      print
      (( n++ ))
    fi
    if (( ${#waits} )); then
      print -r -- "## 更新待ち"
      print
      print -rl -- "- "${^waits}
      print
    fi
    if (( ${#infos} )); then
      print -r -- "## 参考"
      print
      print -rl -- "- "${^infos}
      print
    fi
  } | _ca_md
}

# sudo の要らない対処を実行する（今は Homebrew のバンドルだけ）
ca-fix() {
  emulate -L zsh
  local f=$(_ca_brew_bundle) t
  if [[ ! -e $f ]]; then
    print -r -- "Homebrew のバンドルが見つからない: $f"
  elif [[ -z $(_ca_which $f) ]]; then
    print -r -- "✅ Homebrew のバンドルは対処済み: $f"
  elif [[ ! -w $f ]]; then
    print -r -- "❌ 書き込み権限が無い: $f（所有者を確認する）"
    return 1
  else
    [[ -e $f.orig ]] || cp -p -- $f $f.orig
    t=$(mktemp) || return 1
    ca-strip-filter < $f > $t
    if [[ -s $t ]] && grep -q 'BEGIN CERT' $t; then
      cat -- $t > $f   # 上書きなので所有者とパーミッションは元のまま
      print -r -- "✅ Homebrew のバンドルから除いた: $f（バックアップ: $f.orig）"
    else
      print -r -- "❌ 変換結果が空だったので書き戻していない: $f"
    fi
    rm -f -- $t
  fi
  [[ -n ${UV_SYSTEM_CERTS:-} ]] || print -r -- "ℹ️ UV_SYSTEM_CERTS が未設定。~/.zshenv に export UV_SYSTEM_CERTS=1 を書く"
  print -r -- "sudo や colima の VM での作業が残っていないか、ca-check で確かめる。"
}
