import {
  MAT_SELECT_CONFIG,
  MAT_SELECT_SCROLL_STRATEGY,
  MAT_SELECT_SCROLL_STRATEGY_PROVIDER,
  MAT_SELECT_SCROLL_STRATEGY_PROVIDER_FACTORY,
  MAT_SELECT_TRIGGER,
  MatSelect,
  MatSelectChange,
  MatSelectModule,
  MatSelectTrigger
} from "./chunk-O2E2N22W.js";
import "./chunk-U23LHFGX.js";
import {
  MatError,
  MatFormField,
  MatHint,
  MatLabel,
  MatPrefix,
  MatSuffix
} from "./chunk-2XOTPK4M.js";
import "./chunk-RIVMTDHB.js";
import "./chunk-ASH6NEZB.js";
import "./chunk-OSXOW2ZV.js";
import {
  MatOptgroup,
  MatOption
} from "./chunk-WXU6CPJN.js";
import "./chunk-QDR3OZOE.js";
import "./chunk-DIZ2HEYP.js";
import "./chunk-OCZXLGD5.js";
import "./chunk-DH53F2VB.js";
import "./chunk-AOKR2ESB.js";
import "./chunk-7U4HWISJ.js";
import "./chunk-ZK3V5HNW.js";
import "./chunk-DZUHKMH4.js";
import "./chunk-UTKSSFVW.js";
import "./chunk-UGRWDZBU.js";
import "./chunk-6ZX4U7PU.js";
import "./chunk-3KLGBJU2.js";
import "./chunk-QW2TM77O.js";
import "./chunk-IXOFD6VA.js";
import "./chunk-C5YV7WIV.js";
import "./chunk-Q45C7LPZ.js";
import "./chunk-2TQNFYEP.js";
import "./chunk-432SX2JT.js";
import "./chunk-OLJFQTXZ.js";
import "./chunk-TPE2WGUI.js";
import "./chunk-W2LTXOEH.js";
import "./chunk-72OK35VJ.js";
import "./chunk-E4CDVRJ4.js";
import "./chunk-I5COZSTS.js";
import "./chunk-JNLIHCF3.js";
import "./chunk-NWXXA5RB.js";
import "./chunk-HWYXSU2G.js";
import "./chunk-JRFR6BLO.js";
import "./chunk-MARUHEWW.js";
import "./chunk-OCBFZOLU.js";

// node_modules/@angular/material/fesm2022/select.mjs
var matSelectAnimations = {
  // Represents
  // trigger('transformPanel', [
  //   state(
  //     'void',
  //     style({
  //       opacity: 0,
  //       transform: 'scale(1, 0.8)',
  //     }),
  //   ),
  //   transition(
  //     'void => showing',
  //     animate(
  //       '120ms cubic-bezier(0, 0, 0.2, 1)',
  //       style({
  //         opacity: 1,
  //         transform: 'scale(1, 1)',
  //       }),
  //     ),
  //   ),
  //   transition('* => void', animate('100ms linear', style({opacity: 0}))),
  // ])
  /** This animation transforms the select's overlay panel on and off the page. */
  transformPanel: {
    type: 7,
    name: "transformPanel",
    definitions: [
      {
        type: 0,
        name: "void",
        styles: {
          type: 6,
          styles: { opacity: 0, transform: "scale(1, 0.8)" },
          offset: null
        }
      },
      {
        type: 1,
        expr: "void => showing",
        animation: {
          type: 4,
          styles: {
            type: 6,
            styles: { opacity: 1, transform: "scale(1, 1)" },
            offset: null
          },
          timings: "120ms cubic-bezier(0, 0, 0.2, 1)"
        },
        options: null
      },
      {
        type: 1,
        expr: "* => void",
        animation: {
          type: 4,
          styles: { type: 6, styles: { opacity: 0 }, offset: null },
          timings: "100ms linear"
        },
        options: null
      }
    ],
    options: {}
  }
};
export {
  MAT_SELECT_CONFIG,
  MAT_SELECT_SCROLL_STRATEGY,
  MAT_SELECT_SCROLL_STRATEGY_PROVIDER,
  MAT_SELECT_SCROLL_STRATEGY_PROVIDER_FACTORY,
  MAT_SELECT_TRIGGER,
  MatError,
  MatFormField,
  MatHint,
  MatLabel,
  MatOptgroup,
  MatOption,
  MatPrefix,
  MatSelect,
  MatSelectChange,
  MatSelectModule,
  MatSelectTrigger,
  MatSuffix,
  matSelectAnimations
};
//# sourceMappingURL=@angular_material_select.js.map
