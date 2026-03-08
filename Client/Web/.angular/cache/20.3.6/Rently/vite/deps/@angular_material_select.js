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
} from "./chunk-FR4TQISZ.js";
import "./chunk-NLQQTNUH.js";
import {
  MatError,
  MatFormField,
  MatHint,
  MatLabel,
  MatPrefix,
  MatSuffix
} from "./chunk-RSCL6QY2.js";
import "./chunk-GQWBXB7P.js";
import "./chunk-7KFFMENS.js";
import "./chunk-726WRNLL.js";
import "./chunk-FSQ6SGDK.js";
import "./chunk-RR7KSV65.js";
import {
  MatOptgroup,
  MatOption
} from "./chunk-O7K6STPA.js";
import "./chunk-XA3EVXH3.js";
import "./chunk-UIWU2LEM.js";
import "./chunk-LFETBNCN.js";
import "./chunk-YGOHTK6X.js";
import "./chunk-HYIZPC5I.js";
import "./chunk-TASNWZRD.js";
import "./chunk-SJU2CMVN.js";
import "./chunk-VENV3F3G.js";
import "./chunk-46HAYV32.js";
import "./chunk-KIIX6SVF.js";
import "./chunk-KI66YR3E.js";
import "./chunk-JDYNIPUN.js";
import "./chunk-ZTJIJ3MD.js";
import "./chunk-A43ZI5UY.js";
import "./chunk-6I6GEOCV.js";
import "./chunk-QCLCRMRT.js";
import "./chunk-5EG33CFQ.js";
import "./chunk-FOIJ32LJ.js";
import "./chunk-KHZIJBRY.js";
import "./chunk-IY2SAXYE.js";
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
