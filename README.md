# Urn Model Environment
エージェントベースのポリアの壺モデルを実行する際、実験環境として利用できるDockerイメージ。

以下のツールがインストールされている。

- Julia (v1.8.5)
- Python (v3.9.x)
- Rust (latest)

実験スクリプトや壺モデル本体は含まれていないので、このDockerイメージを元に適宜実験用のDockerイメージを作成すると良い。

## 利用方法
このDockerイメージは GitHub Packages を利用して配布されている。

https://github.com/tsukuba-websci/urn-model-environment/pkgs/container/urn-model-environment

これを利用するためには、Docker に GitHub の認証情報を教えてあげる必要がある。


### 1. Docker と GitHub の連携
https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-with-a-personal-access-token-classic

#### 1-1. GitHub のパーソナルアクセストークンの作成
GitHub のパーソナルアクセストークンは、人間に代わってコンピュータが利用する用のパスワードのこと。
下記URLで作成できる。

https://github.com/settings/tokens/new

推奨設定項目:

| 項目名          | 値                     |
| --------------- | ---------------------- |
| Note            | 自分で決めた好きな名前 |
| Expiration      | No expiration          |
| `read:packages` | ✅                      |

画面最下部の Generate token ボタンを押すとパーソナルアクセストークンが生成されて表示されるので、コピーしておく。
このページを閉じると二度と同じトークンは表示されないので要注意。もしコピーをミスしてしまった場合は最初からやり直す。


#### 1-2. Docker と GitHub の連携
以下のコマンドを実行する。 

```sh
echo "PERSONAL-ACCESS-TOKEN" | docker login ghcr.io -u USERNAME --password-stdin
```

| 変数                    | 値                                       |
| ----------------------- | ---------------------------------------- |
| `PERSONAL-ACCESS-TOKEN` | 先ほど取得したパーソナルアクセストークン |
| `USERNAME`              | GitHubのユーザーID                       |


例: 

```sh
echo "ghp_ThisIsMyPersonalToken" | docker login ghcr.io -u sudame --password-stdin
```

### 2. Dockerfile の作成

```dockerfile
FROM --platform=linux/amd64 ghcr.io/tsukuba-websci/urn-model-environment:latest
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN echo `julia --version`
RUN echo `rustc --version`
RUN echo `python --version`
```

[既知の問題](#既知の問題) に記した通り、このDockerイメージは linux/amd64 向けにしか提供されていないため、 `--platform=linux/amd64` の指定が必要。

## 既知の問題
- Dockerイメージが linux/amd64 向けにしか提供されていない。
  - 理由: AMD64上でARM64向けのDockerイメージをビルドする際、Juliaのバグと思われる挙動によりビルドに失敗するため。
  - 対応: ARM64上で直接ビルドすれば良い。M1/2 Mac上で高速に動作させたい場合などは [Dockerfile](Dockerfile) を自分でビルドするなどして対応してほしい。
