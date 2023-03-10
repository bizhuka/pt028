sap.ui.define([
    'sap/ui/base/Object'
], function (Object) {
    "use strict";

    return Object.extend("zpt028.ext.controller.ReportDialog", {
        owner: null,
        dialog: null,
        sFilter: null,

        initDialog: function (owner, sFilter) {
            const _this = this

            _this.owner = owner
            _this.sFilter = sFilter
            if (!this.dialog) {
                _this.dialog = sap.ui.xmlfragment("reportDialog", "zpt028.ext.fragment.ReportDialog", _this);
                _this.owner.getView().addDependent(_this.dialog);
            }
        },

        _onInit_Inputs: function () {
            sap.ui.getCore().byId("reportDialog--inTprog").setSelectedKeys(['FREE', 'NGHT', 'NIGH'])
        },

        _OnOkPress: function () {
            const arrFilter = []
            for (const sKey of sap.ui.getCore().byId("reportDialog--inTprog").getSelectedKeys())
                arrFilter.push(sKey)
            const addFilter = arrFilter.length > 0 ? " and tprog eq '" + arrFilter.join(',') + "'" : ""

            const dummyDate = "datetime'2000-01-01T00:00:00'"
            const key = {
                begda: dummyDate, endda: dummyDate,
                begda_doc: dummyDate, endda_doc: dummyDate,
                begda_fio: dummyDate, endda_fio: dummyDate,
                begda_addr: dummyDate, endda_addr: dummyDate,
                begda_pos: dummyDate, endda_pos: dummyDate,
                begda_pos_ltext: dummyDate, endda_pos_ltext: dummyDate,
            }

            const sUrl =
                document.location.origin
                + "/sap/opu/odata/sap/ZC_PT028_REPORT_CDS/ZC_PT028_REPORT("
                + "stream_type='1',pernr='00000000'," +
                new URLSearchParams(key).toString().replaceAll('&', ',') + ")/$value?"
                + this.sFilter
                + encodeURI(" and days_from_key_date eq '" + sap.ui.getCore().byId("reportDialog--inDays").getValue().padStart(2, '0').substring(0, 2) + "'")
                + encodeURI(addFilter)

            window.open(sUrl)
            this._doClose()
        },

        _OnCancelPress: function () {
            this._doClose()
        },

        _doClose: function () {
            this.dialog.close()
            this.dialog.destroy()
            this.dialog = null
        }
    });
}
);