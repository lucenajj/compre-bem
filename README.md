# 🛒 Compre Bem

App de mercado em **Flutter** — um código só para **Android, iOS e Web** (e desktop, de quebra).

## O que o app faz

- **Login**: tela inicial com nome e e-mail; a sessão fica salva no aparelho
  (botão "Sair" na barra superior).
- **Escanear**: lê o código de barras com a câmera. Se o produto já estiver
  cadastrado, entra na compra automaticamente; se for novo, abre um modal para
  cadastrar nome, preço e categoria.
- **Compra**: lista os itens escaneados, ajusta quantidades, mostra o total e
  finaliza a compra (salva com a data de hoje).
- **Comparar**: mês atual × mês anterior — totais, variação %, o que você
  comprou este mês e não no anterior, o que não recomprou, e tabela produto
  a produto.
- **Dashboard**: compra mais cara, produto mais/menos comprado, gráfico de
  gasto por mês e ranking de produtos.

Os dados ficam salvos no aparelho (`SharedPreferences`), então funcionam
offline e nas três plataformas.

## Rodando o projeto

Pré-requisito: [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado.

```bash
flutter pub get
flutter run            # roda no dispositivo/emulador conectado ou no Chrome
```

Builds:

```bash
flutter build apk      # Android
flutter build ipa      # iOS (requer macOS com Xcode)
flutter build web      # Web (gera pasta build/web)
```

## Estrutura

```
lib/
  main.dart                 # app + navegação por abas
  models/                   # Product, CartItem, Purchase
  data/seed_data.dart        # catálogo e compras de exemplo
  store/app_store.dart       # estado global + persistência
  screens/                  # scanner, cart, compare, dashboard
  widgets/new_product_dialog.dart  # modal de cadastro
  utils/format.dart          # formatação pt-BR (R$, meses)
```

## Permissão de câmera (Android)

O pacote `mobile_scanner` já declara a permissão de câmera no
`AndroidManifest.xml` gerado. No iOS, adicione em `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>Usamos a câmera para ler códigos de barras dos produtos.</string>
```
