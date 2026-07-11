---
name: flutter-pnsa-ui
description: Use when designing, creating, or modifying UI components, pages, widgets, or theme files for the PNSA Catequese Flutter app. Follows clean Material 3 expressive design with custom AppTheme and AppColors.
---

# PNSA Catequese — Flutter Material 3 Expressive UI

## 10 Diretrizes de Design (Senior Level)

### 1. UX-First Design
Antes de codar lógica, priorize hierarquia visual. Aplique **espaçamentos generosos** (white space), contraste equilibrado e tipografia legível. Use `SizedBox` de 16–24px entre seções, padding de 24–32px nas laterais em telas largas, 8px em mobile. Informação deve respirar.

### 2. Material 3 Moderno
Use componentes nativos M3 (`FilledButton`, `Card`, `NavigationRail`, `NavigationBar`, `Dialog`) com personalização mínima via `AppTheme`. Prefira formas arredondadas (`_shapeSmall` 8, `_shapeMedium` 12, `_shapeLarge` 16), sombras sutis (elevation 1–3), e cores do `ColorScheme` — nunca cores soltas.

### 3. Responsividade Adaptativa
**`LayoutBuilder` sempre para decisões de layout.** Use os breakpoints do projeto (600, 720, 900, 1080). Layouts devem fluir: cards → tabela, rail extendido → colapsado → drawer, formulários side-by-side → empilhados. Nada de tamanhos fixos — use `Expanded`, `Flex`, proporções.

### 4. GetX Module Pattern
Todo código em módulos: `binding`, `controller`, `view`, `model`. A **View é a manifestação pura do design** — sem lógica de negócio. Use `Obx` para reatividade, `ever`/`once` para efeitos colaterais. Controller gerencia estado via `Rx` vars e chama repositórios.

### 5. Micro-Interações e Feedback
Adicione **animações implícitas** em transições de estado:
- `AnimatedContainer` para mudanças de cor/tamanho
- `AnimatedOpacity` para fade in/out
- `AnimatedSwitcher` para troca de widgets
- `InkWell` com `splashFactory: InkSparkle.splashFactory`
- Botões de "Salvar" com `CircularProgressIndicator` + estado `saving` + disabled

A UI deve parecer **viva, suave e responsiva ao toque**.

### 6. Clean Architecture Light
Interface desacoplada da lógica. ViewModels/Controllers não importam widgets. Design deve ser **alterável sem tocar em regras de negócio**. Repositórios isolam Firebase. Models são Dart puros (sem anotações de UI).

### 7. Design Tokens
Valores de estilo **centralizados em classes dedicadas**:
- `AppColors` — cores
- `AppTheme._shapeSmall/Medium/Large` — raios
- `AppTheme.searchInputDecoration()` — search bars
- `ThemeData` no `_buildTheme` — tudo: inputs, botões, cards, navegação

Nunca repetir `BorderRadius.circular(8)` ou `Color(0xFF...)` solto nas views.

### 8. Dependency Injection
**Bindings obrigatórios.** Nunca instanciar controllers dentro de widgets (`Get.put` no binding, não no build). A View recebe o controller via `Get.find()` ou `GetX<Controller>`. View leve e limpa.

### 9. Estado de Interface (UX)
Implementar **3 estados visuais obrigatórios** em toda tela com dados async:
- **Loading**: `CircularProgressIndicator` centralizado ou shimmer/skeleton
- **Empty**: ilustração/ícone + mensagem amigável ("Nenhum item encontrado")
- **Error**: `SnackBar` elegante ou inline error + botão "Tentar novamente"

Nunca mostrar tela vazia sem feedback.

### 10. Código Limpo e Autoexplicativo
Nomenclatura clara que reflita intenção de design. `_buildMetricCard` em vez de `_buildWidget3`. Linting estrito. Modular, profissional, fácil manutenção. **Sem comentários** no código — o nome da função/varável documenta.

---

## Color System (`app_colors.dart`)

| Token | Light | Dark |
|---|---|---|
| `primary` | `#1A3A5C` | `#A8C8FF` |
| `secondary` | `#C8A84E` | `#F5C542` |
| `tertiary` | `#4A8C6F` | `#B2CCC0` |
| `surface` | `#FCFCFF` | `#1A1C1E` |
| `onSurface` | `#1A1C1E` | `#E2E2E6` |
| `onSurfaceVariant` | `#6B7280` | same |

Always use `ColorScheme` from `AppColors.lightColorScheme` / `AppColors.darkColorScheme` — never hardcode hex colors. Use `colorScheme.onSurface.withOpacity(x)` for custom grays.

## Corner Radius Constants (`_shapeSmall = 8`, `_shapeMedium = 12`, `_shapeLarge = 16`)

| Use | Constant | Value |
|---|---|---|
| Buttons, chips, list tiles, menus, snackbars | `_shapeSmall` | `8.0` |
| Cards, inputs, nav indicators | `_shapeMedium` | `12.0` |
| Dialogs, bottom sheets, date/time pickers, drawer, FAB | `_shapeLarge` | `16.0` |

## Global Input Theme

```dart
inputDecorationTheme: InputDecorationTheme(
  filled: true,
  fillColor: isLight
      ? colorScheme.surfaceContainerLow.withOpacity(0.7)
      : colorScheme.surfaceContainerHigh,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(_shapeMedium), // 12
    borderSide: BorderSide(color: colorScheme.outlineVariant),
  ),
  // enabled, focused, error, focusedError borders all use _shapeMedium
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
)
```

This applies to **all form fields** (edit dialogs, forms). Do NOT change it.

## Search Bars (M3 Pill Style)

For **search bars only**, use the centralized method:

```dart
AppTheme.searchInputDecoration(
  theme.colorScheme,
  hintText: 'Buscar algo...',
  suffixIcon: query.isNotEmpty
      ? IconButton(...)
      : null,
  // Optional: contentPadding, isDense, prefixIcon (defaults to search icon)
)
```

This produces:
- `fillColor: onSurface.withOpacity(0.08)` — consistent gray regardless of theme
- `borderRadius: 28` — pill shape, no outline
- Default `prefixIcon: Icons.search_rounded`
- `contentPadding: EdgeInsets.symmetric(vertical: 0)`

Every search bar in the app MUST use this method. Currently used in:
- catequista_page.dart, coordenador_page.dart, catequizando_page.dart, turma_page.dart, encontros_page.dart (2x)

## Responsividade Profissional (Breakpoints)

### Breakpoints do Projeto

| Nome | Largura | Uso |
|---|---|---|
| `mobile` | < 600px | Cards empilhados, drawer, padding `hPad = 8` |
| `tablet` | 600–719px | Transição, tabelas compactas ou cards |
| `wide` | 720–1079px | NavigationRail colapsado, tabelas completas |
| `desktop` | ≥ 900px | Diálogos largos (`560–640px`), formulários side-by-side |
| `extra-wide` | ≥ 1080px | NavigationRail extendido com labels visíveis |

### 1. Navegação (3-tier)

```dart
LayoutBuilder(
  builder: (context, constraints) {
    final width = constraints.maxWidth;
    if (width >= 1080) return _ExtraWideLayout(vm: vm, theme: theme);  // NavigationRail extended
    if (width >= 720) return _WideLayout(vm: vm, theme: theme);         // NavigationRail collapsed
    return _NarrowLayout(vm: vm, theme: theme);                          // Drawer
  },
);
```

- **Extra-wide (≥1080)**: `NavigationRail(extended: true, labelType: NavigationRailLabelType.none)` — labels sempre visíveis, `minExtendedWidth: 200`
- **Wide (720–1079)**: `NavigationRail(extended: false, labelType: NavigationRailLabelType.all)` — icones + labels em coluna
- **Narrow (<720)**: Drawer com hamburger — sem NavigationRail nem NavigationBar

Ambos (Rail e Bar) usam `primaryContainer` como cor do indicador e `_shapeMedium` (12) no `indicatorShape`.

### 2. Páginas de Lista — Cards ↔ Tabela (breakpoint 600px)

Toda página com listagem (catequistas, catequizandos, turmas, coordenadores) segue este padrão:

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth < 600) {
      return Column(children: list.map((i) => _ItemCard(item: i)).toList());
    }
    return _ItemTable(items: list);
  },
);
```

- `< 600`: cards empilhados com `ListView.builder(shrinkWrap: true, physics: NeverScrollableScrollPhysics())`
- `≥ 600`: `DataTable` com colunas completas

### 3. Diálogos (3-tier)

```dart
final screenWidth = MediaQuery.of(context).size.width;
final dialogWidth = screenWidth > 900 ? 560.0 : screenWidth > 600 ? 480.0 : screenWidth * 0.92;
```

- **< 600**: `screenWidth * 0.92` — quase fullscreen
- **600–900**: `480.0` (catequizando: `560.0`)
- **> 900**: `560.0` (catequizando: `640.0`)

### 4. Padding Horizontal (`hPad`)

```dart
final hPad = MediaQuery.of(context).size.width < 600 ? 8.0 : 32.0;
```

Usar no `padding` de cada página (`EdgeInsets.fromLTRB(hPad, ... )`). Login usa `24.0` em vez de `32.0` para telas largas.

### 5. Home — Metric Cards (Row ↔ Column, breakpoint 600px)

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth > 600) {
      return Row(children: [Expanded(_MetricCard), spacing 16, Expanded(_MetricCard), spacing 16, Expanded(_MetricCard)]);
    }
    return Column(children: [_MetricCard, spacing 16, _MetricCard, spacing 16, _MetricCard]);
  },
);
```

Status cards seguem o mesmo padrão: `Row` com `Expanded` em wide, `Wrap` com `SizedBox(width: (maxWidth-8)/2)` em narrow (grid 2-colunas).

### 6. Login — Large vs Compact (breakpoint 900px)

```dart
LayoutBuilder(
  builder: (context, constraints) {
    if (constraints.maxWidth >= 900) return _LargeScreen(vm: vm);  // Row: hero panel (flex 5) + form (flex 4)
    return _CompactScreen(vm: vm);                                   // SingleChildScrollView centered, maxWidth 380
  },
);
```

### 7. Wizard (Catequizando) — Desktop vs Mobile (breakpoint 900px)

```dart
final isLarge = MediaQuery.of(context).size.width > 900;
if (isLarge) {
  // Row: sidebar + divider + content + bottom bar
} else {
  // Column: step indicator + content + bottom bar
}
```

- **Desktop (≥900)**: sidebar fixa à esquerda com etapas, formulário à direita, padding 40
- **Mobile (<900)**: step indicator horizontal no topo, formulário abaixo, padding 24

### Regra de Ouro

**Sempre usar `LayoutBuilder` para decisões de layout** (nunca `MediaQuery` dentro do build). `MediaQuery` é aceitável apenas para `hPad` e `dialogWidth` calculados uma vez por frame. `OrientationBuilder` não é usado no projeto.

### Resumo por Arquivo

| Arquivo | Breakpoint | Técnica |
|---|---|---|
| `home_page.dart` | 600, 720, 1080 | `LayoutBuilder` (3-tier nav + metric/status cards) |
| `catequista_page.dart` | 600 | `LayoutBuilder` (card ↔ table) |
| `coordenador_page.dart` | 600 | `LayoutBuilder` (card ↔ table) |
| `catequizando_page.dart` | 600 | `LayoutBuilder` (card ↔ table) |
| `turma_page.dart` | 600 | `LayoutBuilder` (card ↔ table) |
| `login_page.dart` | 900 | `LayoutBuilder` (large ↔ compact) |
| `catequizando_wizard.dart` | 900 | `MediaQuery` (desktop sidebar ↔ mobile) |
| `relatorio_page.dart` | 600 | `MediaQuery` (hPad) |
| `sobre_page.dart` | 600 | `MediaQuery` (hPad) |
| `encontros_page.dart` | 600 | `MediaQuery` (hPad) |

## GetX State Management

- `Obx` for reactive widgets
- `ever()` worker to react to changes (e.g., `firestoreUser` for menu visibility)
- ViewModels extend `GetxController`
- Use `Future.wait` with `.count().get()` for parallel Firebase count queries

## Pencil (.pen) Design Files

The app has a high-fidelity design in `sistema.pen` (Pencil file). When working on UI:
1. Open the `.pen` file via `pencil_open_document`
2. Use `pencil_batch_get` to explore component structure
3. Use `pencil_batch_design` to create/modify screens
4. Use `pencil_get_variables` to extract design tokens
5. Export with `pencil_export_nodes` for screenshots

## Key Conventions

- **Never add comments** to code
- **No emojis** in code or UI
- All firestore queries in ViewModels (`_loadData`, `setSearch`, pagination)
- PDF generators (`CertificateGenerator`, `RelatorioGenerator`) include `logo.jpg` in headers
- `assets/images/` contains `logo.jpg` and `app_icon.png` (registered in `pubspec.yaml`)
