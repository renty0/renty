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
} from "./chunk-R3VLFBIF.js";
import "./chunk-SM5YLAIO.js";
import {
  MatError,
  MatFormField,
  MatHint,
  MatLabel,
  MatPrefix,
  MatSuffix
} from "./chunk-37FYTC4C.js";
import "./chunk-GQWBXB7P.js";
import "./chunk-2DB3TZGX.js";
import "./chunk-726WRNLL.js";
import "./chunk-FSQ6SGDK.js";
import {
  MatOptgroup,
  MatOption
} from "./chunk-VQ3ICSVU.js";
import "./chunk-XA3EVXH3.js";
import "./chunk-UIWU2LEM.js";
import "./chunk-LFETBNCN.js";
import "./chunk-FDT6TTLD.js";
import "./chunk-UNJPXBFU.js";
import "./chunk-TASNWZRD.js";
import "./chunk-SJU2CMVN.js";
import "./chunk-VENV3F3G.js";
import "./chunk-46HAYV32.js";
import "./chunk-KIIX6SVF.js";
import "./chunk-K5BXQKC7.js";
import "./chunk-A43ZI5UY.js";
import "./chunk-JDYNIPUN.js";
import "./chunk-ZTJIJ3MD.js";
import "./chunk-GUL6XPIM.js";
import "./chunk-QCLCRMRT.js";
import "./chunk-5EG33CFQ.js";
import "./chunk-KHZIJBRY.js";
import "./chunk-FOIJ32LJ.js";
import "./chunk-IY2SAXYE.js";
import "./chunk-RR7KSV65.js";
import "./chunk-IGUAJKSF.js";
import "./chunk-ZMLREZMJ.js";
import "./chunk-3Z4HVEDU.js";
import "./chunk-OZB3DDOT.js";
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
