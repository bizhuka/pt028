sap.ui.controller("zpt028.ext.controller.ObjectPageExtension", {

	_prefix: 'zpt028::sap.suite.ui.generic.template.ObjectPage.view.Details::ZC_PT028_REPORT--',

	_data: {
		title: '',
		startDate: new Date(),
		schedule: []
	},

	onInit: function () {
		window._objectPage = this

		const _view = this.getView()
		const objectPage = _view.byId(this._prefix + "objectPage")
		if (objectPage)
			objectPage.setUseIconTabBar(true)

		this._oModel = new sap.ui.model.json.JSONModel()
		this._oModel.setData(this._data)

		this.getView().byId('SinglePlanningCalendar').setModel(this._oModel, "calendar")
	},

	onAfterRendering: function () {
		this.readCurrentSchedule()
	},

	_refreshCalendar: function () {
		this._oModel.updateBindings()
	},

	startDateChangeHandler: function (oEvent) {
		this.readCurrentSchedule(null, oEvent.getParameter('date'))
	},

	readCurrentSchedule: function (nPernr, month) {
		const _this = this

		if (!month)
			month = new Date(sap.ui.getCore().byId('zpt028::sap.suite.ui.generic.template.ListReport.view.ListReport::ZC_PT028_REPORT--dpKeyDate').getValue())

		if (!month)
			month = new Date()
		_this._data.title = month.getFullYear() + " - " + month.toLocaleString('default', { month: 'long' })
		_this._data.startDate = month

		if (!nPernr) {
			const urlPart = "pernr='"
			const iFrom = window.location.href.indexOf(urlPart)
			nPernr = window.location.href.substring(iFrom + urlPart.length, iFrom + urlPart.length + 8)
		}
		_this.getView().getModel().read("/ZC_PT028_Schedule", {
			urlParameters: {
				"$select": "begda,endda,tprog,kind,info",
				"$filter": "datum eq datetime'" + _this.getDateIso(month) + "T00:00:00' and pernr eq '" + nPernr + "'"
			},
			success: function (data) {
				_this._data.schedule = []

				for (item of data.results) {
					const calendarItem = {
						start: item.begda,
						end: item.endda,
						title: item.tprog,
						type: 'Type' + item.kind,
						info: item.info
					}
					_this._data.schedule.push(calendarItem)
				}
				_this._refreshCalendar()
			},
			error: function (oError) {
				console.log(oError)
			}
		})
	},

	// TODO make lib
	getDateIso: function (date) {
		const okDate = new Date(date.getTime() - (date.getTimezoneOffset() * 60 * 1000))
		return okDate.toISOString().split('T')[0]
	}
});
