# 🎰 slingo

**Slingo** — part slots, part bingo, all luck — built with
[miso](https://github.com/dmjio/miso) and compiled to WebAssembly.
Two tables: a faithful clone of the **1994 AOL classic** on green
felt, and a **modern** neon-styled remix.

- 🎲 A 5×5 bingo-style card (columns 1–15 … 61–75) and 20 spins of five
  reels, one under each column — matches mark themselves
- 🃏 Jokers pause the table: pick any open tile in that column (super
  jokers pick anywhere) — glowing tiles show your options
- ⌨️ Space or Enter spins; a screen-filling **SLINGO!** slam when a line
  lands
- 🔊 Sound effects synthesized live with the Web Audio API (zero assets)
- ✨ Built on `Miso.Lens`, `Miso.CSS`, and `Miso.CSS.Color`

## Classic '94 rules

The published scoring of the original AOL game (per the archived
Encyclopedia Gamia / Wikipedia scoring table): +200 a number, +1,000 a
slingo or a coin, and 3/4/5 jokers in one spin pay 1,000 / 2,500 /
10,000. Only the center reel can go 🌟 super, and a super joker is
played first. The 😈 devil halves your score unless the 😇 cherub
shoots it (about half the time). 🔄 free spins are held in hand to pay
for spins 17–20, which cost 500–2,000 points. A full card is worth
6,000–11,000 — the fewer spins you needed, the fatter the bonus. The
look to match: green felt, beveled cream tiles, chrome reels, a big
red spin button, and a gold coin slapped on every mark.

## Modern rules

😈 Devils halve your score on the spot; 😇 cherubs stay in hand and
block them; 🪙 coins (+50) and 🔄 free spins sweeten the reels. 12
slingo lines at +200 each, +20 per tile, and a +1000 full-card jackpot
plus +100 for every spin you didn't need — all in neon gold, pink, and
cyan on deep violet velvet.

## Build (WASM)

Enter the nix shell and run make:

```bash
nix develop .#wasm --command make
make serve   # serves public/ on :8080
```

## Development

```bash
make build   # wasm32-wasi-cabal build + post-link + copy static
make optim   # wasm-opt + strip
```

## Tests

Native (non-WASM) correctness tests cover the line geometry, card
generation, reel rolls, and board helpers:

```bash
nix develop --command cabal test
```
