-----------------------------------------------------------------------------
-- | Sound effects synthesized with the Web Audio API — no audio assets.
-- 'soundInit' must run inside a user gesture (the PLAY button click)
-- so the AudioContext is allowed to play.
-----------------------------------------------------------------------------
module Sound
  ( soundInit
  , playSound
  ) where
-----------------------------------------------------------------------------
import           Control.Monad (when)
-----------------------------------------------------------------------------
import           Miso.FFI.QQ (js)
import           Miso.String (MisoString)
-----------------------------------------------------------------------------
-- | Build the tiny synth once and park it on @globalThis.__ms@.
soundInit :: IO ()
soundInit = [js|
  if (!globalThis.__ms) {
    var AC = window.AudioContext || window.webkitAudioContext;
    var ctx = new AC();
    var master = ctx.createGain();
    master.gain.value = 0.5;
    master.connect(ctx.destination);
    function noiseBuf(dur) {
      var n = Math.floor(ctx.sampleRate * dur);
      var b = ctx.createBuffer(1, n, ctx.sampleRate);
      var d = b.getChannelData(0);
      for (var i = 0; i < n; i++) d[i] = Math.random() * 2 - 1;
      return b;
    }
    function env(g, t0, a, peak, d) {
      g.gain.setValueAtTime(0, t0);
      g.gain.linearRampToValueAtTime(peak, t0 + a);
      g.gain.exponentialRampToValueAtTime(0.0001, t0 + a + d);
    }
    function tone(freq, type, t0, a, peak, d) {
      var o = ctx.createOscillator();
      o.type = type;
      o.frequency.value = freq;
      var g = ctx.createGain();
      env(g, t0, a, peak, d);
      o.connect(g);
      g.connect(master);
      o.start(t0);
      o.stop(t0 + a + d + 0.05);
    }
    function gliss(f0, f1, type, t0, a, peak, d) {
      var o = ctx.createOscillator();
      o.type = type;
      o.frequency.setValueAtTime(f0, t0);
      o.frequency.exponentialRampToValueAtTime(Math.max(f1, 30), t0 + a + d);
      var g = ctx.createGain();
      env(g, t0, a, peak, d);
      o.connect(g);
      g.connect(master);
      o.start(t0);
      o.stop(t0 + a + d + 0.05);
    }
    function burst(t0, dur, f0, f1, peak) {
      var s = ctx.createBufferSource();
      s.buffer = noiseBuf(dur + 0.02);
      var f = ctx.createBiquadFilter();
      f.type = 'bandpass';
      f.frequency.setValueAtTime(f0, t0);
      f.frequency.exponentialRampToValueAtTime(Math.max(f1, 40), t0 + dur);
      f.Q.value = 1.1;
      var g = ctx.createGain();
      env(g, t0, 0.003, peak, dur);
      s.connect(f);
      f.connect(g);
      g.connect(master);
      s.start(t0);
    }
    globalThis.__ms = {
      ctx: ctx,
      play: function (name) {
        if (ctx.state === 'suspended') ctx.resume();
        var t = ctx.currentTime + 0.01;
        var i, j, ns;
        if (name === 'deal') {
          for (i = 0; i < 6; i++) {
            burst(t + i * 0.05, 0.04, 2000 + (i % 3) * 400, 900, 0.25);
          }
          tone(523.25, 'triangle', t + 0.3, 0.01, 0.2, 0.3);
        } else if (name === 'spin') {
          burst(t, 0.5, 600, 2600, 0.2);
          for (i = 0; i < 8; i++) {
            burst(t + i * 0.055, 0.02, 2600, 1800, 0.12);
          }
        } else if (name === 'stop') {
          burst(t, 0.05, 2200, 800, 0.5);
          tone(196, 'sine', t, 0.002, 0.3, 0.07);
        } else if (name === 'mark') {
          tone(659.25, 'sine', t, 0.004, 0.3, 0.12);
          tone(987.77, 'sine', t + 0.05, 0.004, 0.25, 0.18);
        } else if (name === 'coin') {
          tone(987.77, 'square', t, 0.002, 0.16, 0.06);
          tone(1318.5, 'square', t + 0.06, 0.002, 0.16, 0.22);
        } else if (name === 'free') {
          gliss(440, 1320, 'triangle', t, 0.01, 0.3, 0.22);
        } else if (name === 'wild') {
          ns = [880, 1108.7, 1318.5];
          for (j = 0; j < ns.length; j++) {
            tone(ns[j], 'sine', t + j * 0.06, 0.005, 0.25, 0.25);
          }
        } else if (name === 'cherub') {
          ns = [523.25, 659.25, 783.99];
          for (j = 0; j < ns.length; j++) {
            tone(ns[j], 'triangle', t + j * 0.04, 0.02, 0.2, 0.6);
          }
        } else if (name === 'devil') {
          gliss(160, 55, 'square', t, 0.01, 0.3, 0.45);
          burst(t, 0.3, 300, 90, 0.3);
        } else if (name === 'slingo') {
          ns = [523.25, 659.25, 783.99, 1046.5];
          for (j = 0; j < ns.length; j++) {
            tone(ns[j], 'square', t + j * 0.07, 0.005, 0.16, 0.3);
            tone(ns[j] * 2, 'sine', t + j * 0.07, 0.005, 0.12, 0.3);
          }
          tone(1567.98, 'sine', t + 0.3, 0.01, 0.3, 0.5);
        } else if (name === 'win') {
          ns = [523.25, 659.25, 783.99, 1046.5, 1318.5, 1567.98];
          for (j = 0; j < ns.length; j++) {
            tone(ns[j], 'sine', t + j * 0.1, 0.01, 0.4, 0.7);
            tone(ns[j] * 2, 'sine', t + j * 0.1, 0.01, 0.12, 0.5);
          }
          tone(261.63, 'triangle', t, 0.02, 0.22, 1.8);
          for (i = 0; i < 10; i++) {
            tone(900 + Math.random() * 1400, 'sine', t + 0.5 + i * 0.07, 0.005, 0.1, 0.3);
          }
        } else if (name === 'over') {
          ns = [392, 349.23, 293.66, 261.63];
          for (j = 0; j < ns.length; j++) {
            tone(ns[j], 'triangle', t + j * 0.16, 0.01, 0.3, 0.5);
          }
        } else if (name === 'deny') {
          tone(110, 'square', t, 0.004, 0.3, 0.11);
          tone(92, 'square', t + 0.07, 0.004, 0.25, 0.13);
        } else if (name === 'blank') {
          tone(330, 'sine', t, 0.004, 0.12, 0.1);
        }
      }
    };
  }
|]
-----------------------------------------------------------------------------
-- | Play a named effect (respecting the model's sound toggle).
playSound :: Bool -> MisoString -> IO ()
playSound enabled name = when enabled
  [js| if (globalThis.__ms) { globalThis.__ms.play(${name}); } |]
