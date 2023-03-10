//@ui5-bundle zpt028/Component-preload.js
jQuery.sap.registerPreloadedModules({
"version":"2.0",
"modules":{
	"zpt028/Component.js":function(){sap.ui.define(["sap/suite/ui/generic/template/lib/AppComponent"],function(e){"use strict";return e.extend("zpt028.Component",{metadata:{manifest:"json"}})});
},
	"zpt028/ext/controller/ListReportExtension.controller.js":function(){sap.ui.controller("zpt028.ext.controller.ListReportExtension",{_prefix:"zpt028::sap.suite.ui.generic.template.ListReport.view.ListReport::ZC_PT028_REPORT--",onInit:function(){window._main_table=this.getView().byId(this._prefix+"responsiveTable");this.getView().byId("dpKeyDate").setValue(this.getDateIso(new Date));const e=this.getView().byId(this._prefix+"listReportFilter");e.setLiveMode(true);e.setShowClearOnFB(true);window._main_table.attachItemPress(function(e){const t=e.getParameters().listItem.getBindingContext().getObject();if(window._objectPage)window._objectPage.readCurrentSchedule(t.pernr)})},getDateIso:function(e){const t=new Date(e.getTime()-e.getTimezoneOffset()*60*1e3);return t.toISOString().split("T")[0]},onAfterRendering:function(e){this._setMessageParser();this._initReportMenu()},_setMessageParser:function(){const e=this.getView();const t=e.getModel();sap.ui.require(["zpt028/ext/controller/MessageParser"],function(e){const i=new e(t.sServiceUrl,t.oMetadata,!!t.bPersistTechnicalMessages);t.setMessageParser(i)})},_initReportMenu:function(){const e=this;const t=e.getView();const i=e._prefix+"report-xlsx";if(t.byId(i))return;const n={id:i,text:"Report",icon:"sap-icon://excel-attachment",press:function(){const i=t.byId(e._prefix+"responsiveTable");const n=i.getBinding("items").sFilterParams;const s=decodeURIComponent(n);if(s.indexOf("and key_date eq datetime'")===-1){sap.m.MessageToast.show("Please specify at least one filter except obligatory",{duration:3500});$(".sapMMessageToast").css("background","#cc1919");return}sap.ui.require(["zpt028/ext/controller/ReportDialog"],function(t){if(!e.reportDialog)e.reportDialog=new t;e.reportDialog.initDialog(e,n);e.reportDialog.dialog.open()})}};const s=t.byId(this._prefix+"listReport-btnExcelExport");if(s)s.getMenu().addItem(new sap.m.MenuItem(n));else t.byId(e._prefix+"template::ListReport::TableToolbar").addContent(new sap.m.Button(n))},onBeforeRebindTableExtension:function(e){var t=e.getParameter("bindingParams");t.parameters=t.parameters||{};var i=e.getSource();var n=this.byId(i.getSmartFilterId());if(!n instanceof sap.ui.comp.smartfilterbar.SmartFilterBar)return;var s=n.getControlByKey("cfKeyDate");if(!s instanceof sap.m.Switch)return;t.filters.push(new sap.ui.model.Filter("key_date","EQ",s.getValue()))},onInitSmartFilterBarExtension:function(e){this.getView().byId(this._prefix+"template:::ListReportPage:::DynamicPageTitle").setVisible(false)}});
},
	"zpt028/ext/controller/MessageParser.js":function(){sap.ui.define(["sap/ui/model/odata/ODataMessageParser"],function(e){"use strict";return e.extend("zpt028.ext.controller.MessageParser",{parse:function(s,r,t,a,n){var o=this;e.prototype.parse.apply(o,arguments);if(s.statusCode<400||s.statusCode>=600)return;const i={request:r,response:s,url:r.requestUri};const u=this._parseBody(s,i);const c=[];const p=[];for(let e of u){if(e.message.indexOf("An exception was raised")===-1&&e.message.indexOf("In the context of Data Services an unknown internal server error occurred")===-1)c.push(e.message);p.push(e.type)}if(c.length===0)return;sap.m.MessageToast.show(c.join("\n"),{duration:3500});if(p.indexOf("Error")>=0)$(".sapMMessageToast").css("background","#cc1919")}})});
},
	"zpt028/ext/controller/ObjectPageExtension.controller.js":function(){sap.ui.controller("zpt028.ext.controller.ObjectPageExtension",{_prefix:"zpt028::sap.suite.ui.generic.template.ObjectPage.view.Details::ZC_PT028_REPORT--",_data:{title:"",startDate:new Date,schedule:[]},onInit:function(){window._objectPage=this;const e=this.getView();const t=e.byId(this._prefix+"objectPage");if(t)t.setUseIconTabBar(true);this._oModel=new sap.ui.model.json.JSONModel;this._oModel.setData(this._data);this.getView().byId("SinglePlanningCalendar").setModel(this._oModel,"calendar")},onAfterRendering:function(){this.readCurrentSchedule()},_refreshCalendar:function(){this._oModel.updateBindings()},startDateChangeHandler:function(e){this.readCurrentSchedule(null,e.getParameter("date"))},readCurrentSchedule:function(e,t){const n=this;if(!t)t=new Date(sap.ui.getCore().byId("zpt028::sap.suite.ui.generic.template.ListReport.view.ListReport::ZC_PT028_REPORT--dpKeyDate").getValue());if(!t)t=new Date;n._data.title=t.getFullYear()+" - "+t.toLocaleString("default",{month:"long"});n._data.startDate=t;if(!e){const t="pernr='";const n=window.location.href.indexOf(t);e=window.location.href.substring(n+t.length,n+t.length+8)}n.getView().getModel().read("/ZC_PT028_Schedule",{urlParameters:{$select:"begda,endda,tprog,kind,info",$filter:"datum eq datetime'"+n.getDateIso(t)+"T00:00:00' and pernr eq '"+e+"'"},success:function(e){n._data.schedule=[];for(item of e.results){const e={start:item.begda,end:item.endda,title:item.tprog,type:"Type"+item.kind,info:item.info};n._data.schedule.push(e)}n._refreshCalendar()},error:function(e){console.log(e)}})},getDateIso:function(e){const t=new Date(e.getTime()-e.getTimezoneOffset()*60*1e3);return t.toISOString().split("T")[0]}});
},
	"zpt028/ext/controller/ReportDialog.js":function(){sap.ui.define(["sap/ui/base/Object"],function(e){"use strict";return e.extend("zpt028.ext.controller.ReportDialog",{owner:null,dialog:null,sFilter:null,initDialog:function(e,o){const t=this;t.owner=e;t.sFilter=o;if(!this.dialog){t.dialog=sap.ui.xmlfragment("reportDialog","zpt028.ext.fragment.ReportDialog",t);t.owner.getView().addDependent(t.dialog)}},_onInit_Inputs:function(){sap.ui.getCore().byId("reportDialog--inTprog").setSelectedKeys(["FREE","NGHT","NIGH"])},_OnOkPress:function(){const e=[];for(const o of sap.ui.getCore().byId("reportDialog--inTprog").getSelectedKeys())e.push(o);const o=e.length>0?" and tprog eq '"+e.join(",")+"'":"";const t="datetime'2000-01-01T00:00:00'";const n={begda:t,endda:t,begda_doc:t,endda_doc:t,begda_fio:t,endda_fio:t,begda_addr:t,endda_addr:t,begda_pos:t,endda_pos:t,begda_pos_ltext:t,endda_pos_ltext:t};const a=document.location.origin+"/sap/opu/odata/sap/ZC_PT028_REPORT_CDS/ZC_PT028_REPORT("+"stream_type='1',pernr='00000000',"+new URLSearchParams(n).toString().replaceAll("&",",")+")/$value?"+this.sFilter+encodeURI(" and days_from_key_date eq '"+sap.ui.getCore().byId("reportDialog--inDays").getValue().padStart(2,"0").substring(0,2)+"'")+encodeURI(o);window.open(a);this._doClose()},_OnCancelPress:function(){this._doClose()},_doClose:function(){this.dialog.close();this.dialog.destroy();this.dialog=null}})});
},
	"zpt028/ext/controller/SPCalendar.js":function(){sap.ui.define(["sap/m/SinglePlanningCalendar"],function(n){"use strict";return n.extend("zpt028.ext.controller.SPCalendar",{})});
},
	"zpt028/ext/controller/SPCalendarRenderer.js":function(){sap.ui.define(["sap/m/SinglePlanningCalendarRenderer","sap/ui/core/InvisibleText","sap/ui/core/Core","sap/ui/unified/library"],function(e,a,t,l){"use strict";var i={apiVersion:2};var n=l.CalendarDayType;i.render=function(e,a){var t=a._getHeader(),l=a._getCurrentGrid();e.openStart("div",a);e.accessibilityState({role:"region",roledescription:a._oRB.getText("SPC_CONTROL_NAME"),labelledby:{value:t.getId()+"-Title "+l.getId()+"-nowMarkerText",append:true}});e.class("sapMSinglePC");e.openEnd();l.getRenderer().renderAppointment=i._ownRenderAppointment;e.renderControl(t);e.renderControl(l);e.close("div")};i._ownRenderAppointment=function(e,l,i,r,p,o){var s=i.data,d=i.width,c=i.level,g=l._getColumns(),u=s.getTooltip_AsString(),b=s.getType(),f=s.getColor(),v=s.getTitle(),C=s.getText(),T=s.getIcon(),A=s.getId(),y=s.getParent().getEnableAppointmentsDragAndDrop(),S={role:"listitem",labelledby:{value:a.getStaticId("sap.ui.unified","APPOINTMENT"),append:true},selected:null},I=g-r-d,E=t.getConfiguration().getRTL(),h,m=t.getConfiguration().getTheme().indexOf("_hc")?2:1;I=I<0?0:I;if(v){S["labelledby"].value=S["labelledby"].value+" "+A+"-Title"}S["labelledby"].value=S["labelledby"].value+" "+A+"-Descr";if(C){S["labelledby"].value=S["labelledby"].value+" "+A+"-Text"}if(s.getTentative()){S["labelledby"].value=S["labelledby"].value+" "+a.getStaticId("sap.ui.unified","APPOINTMENT_TENTATIVE")}if(s.getSelected()){S["labelledby"].value=S["labelledby"].value+" "+a.getStaticId("sap.ui.unified","APPOINTMENT_SELECTED")}e.openStart("div",s.getId()+"-"+r+"_"+o);e.attr("draggable",y);e.attr("data-sap-ui-draggable",y);e.attr("data-sap-ui-related",s.getId());e.attr("data-sap-level",c);e.attr("data-sap-width",d);e.attr("tabindex",0);if(u){e.attr("title",u)}e.accessibilityState(s,S);e.class("sapMSinglePCAppointmentWrap");e.class("sapUiCalendarRowApps");if(!f&&b!==n.None){e.class("sapUiCalendarApp"+b)}if(f){if(t.getConfiguration().getRTL()){e.style("border-right-color",f)}else{e.style("border-left-color",f)}}e.style(E?"right":"left","calc("+r*100/g+"% + "+m+"px)");e.style(E?"left":"right","calc("+I*100/g+"% + "+m+"px)");e.style("top",c*p.appHeight+p.cellHeaderHeight+"rem");e.openEnd();e.openStart("div");e.class("sapUiCalendarApp");e.style("height","3rem");if(s.getSelected()){e.class("sapUiCalendarAppSel")}if(s.getTentative()){e.class("sapUiCalendarAppTent")}if(T){e.class("sapUiCalendarAppWithIcon")}e.openEnd();e.openStart("div");e.class("sapUiCalendarAppCont");if(f){e.style("background-color",s._getCSSColorForBackground(f))}e.openEnd();if(i.hasPrevious<0){h=["sapUiCalendarAppArrowIconLeft","sapUiCalendarAppArrowIcon"];e.icon("sap-icon://arrow-left",h,{title:null,role:"img"})}if(T){h=["sapUiCalendarAppIcon"];var x={};x["id"]=A+"-Icon";x["title"]=null;x["role"]="img";e.icon(T,h,x)}e.openStart("div");e.class("sapUiCalendarAppTitleWrapper");e.openEnd();if(v){e.openStart("span",A+"-Title");e.class("sapUiCalendarAppTitle");e.openEnd();e.text(v,true);e.close("span")}if(C){e.openStart("span",A+"-Text");e.class("sapUiCalendarAppText");e.openEnd();e.text(C,false);e.close("span")}e.close("div");if(i.hasNext<0){h=["sapUiCalendarAppArrowIconRight","sapUiCalendarAppArrowIcon"];e.icon("sap-icon://arrow-right",h,{title:null,role:"img"})}e.openStart("span",A+"-Descr");e.class("sapUiInvisibleText");e.openEnd();e.text(l._getAppointmentAnnouncementInfo(s));e.close("span");e.close("div");e.close("div");e.close("div")};return i},true);
},
	"zpt028/ext/fragment/CustomFilter.fragment.xml":'<core:FragmentDefinition xmlns="sap.m" xmlns:smartfilterbar="sap.ui.comp.smartfilterbar" xmlns:core="sap.ui.core"><smartfilterbar:ControlConfiguration key="cfKeyDate" label="Key Date" visibleInAdvancedArea="true" groupId="_BASIC" mandatory="mandatory"><smartfilterbar:customControl><DatePicker id="dpKeyDate" displayFormat="long" valueFormat="yyyy-MM-dd"/></smartfilterbar:customControl></smartfilterbar:ControlConfiguration></core:FragmentDefinition>\r\n',
	"zpt028/ext/fragment/ReportDialog.fragment.xml":'<core:FragmentDefinition xmlns="sap.m" xmlns:form="sap.ui.comp.smartform" xmlns:core="sap.ui.core"><Dialog class="sapUiPopupWithPadding" title="Excel report" resizable="false" draggable="false" showHeader="true" horizontalScrolling="false" contentWidth="23em" afterOpen="_onInit_Inputs"><content><form:SmartForm id="root_grp" title="" editable="true"><form:layout><form:ColumnLayout columnsM="1" columnsL="1" columnsXL="1" /></form:layout><form:Group label="Highlight options:"><form:GroupElement label=\'Daily WS\'><MultiComboBox id="inTprog" items="{/ZC_PT028_ScheduleKind}"><core:Item key="{tprog}" text="{tprog}" /></MultiComboBox></form:GroupElement><form:GroupElement label=\'Days from Key Date\'><Input id="inDays" type="Number" required="true" value="31" maxLength="2" /></form:GroupElement></form:Group></form:SmartForm></content><buttons><Button text="Ok" type="Emphasized" press="_OnOkPress" /><Button text="Cancel" type="Emphasized" press="_OnCancelPress" /></buttons></Dialog></core:FragmentDefinition>\r\n',
	"zpt028/ext/fragment/Schedule.fragment.xml":'<core:FragmentDefinition  xmlns="sap.m"\n                          xmlns:l="sap.ui.layout"\n\t\t\t\t\t\t  xmlns:unified="sap.ui.unified"\n\t\t\t\t\t\t  xmlns:core="sap.ui.core"\n                          xmlns:zz="zpt028.ext.controller"\n\t ><l:VerticalLayout width="100%" id="WorkSchedule"><zz:SPCalendar\n\t\t\tid="SinglePlanningCalendar"\n            title="{calendar>/title}"\n\t\t    startDateChange=".startDateChangeHandler"\n\t\t\tappointments="{calendar>/schedule}"\n\t\t\tstartDate="{calendar>/startDate}"\n\t\t\tfirstDayOfWeek="1"><zz:views><SinglePlanningCalendarMonthView\n\t\t\t\t\tkey="OneMonth"\n\t\t\t\t\ttitle="Month"/></zz:views><zz:appointments><unified:CalendarAppointment\n\t\t\t\t\tstartDate="{calendar>start}"\n\t\t\t\t\tendDate="{calendar>end}"\n\t\t\t\t\ttitle="{calendar>title}"\n                    text="{calendar>info}"\n\t\t\t\t\ttype="{calendar>type}"></unified:CalendarAppointment></zz:appointments></zz:SPCalendar></l:VerticalLayout></core:FragmentDefinition>\n',
	"zpt028/i18n/i18n.properties":'# This is the resource bundle for zpt028\n\n#Texts for manifest.json\n\n#XTIT: Application name\nappTitle=Onshift report\n\n#YDES: Application description\nappDescription=Onshift report',
	"zpt028/manifest.json":'{"_version":"1.44.0","sap.app":{"id":"zpt028","type":"application","i18n":"i18n/i18n.properties","applicationVersion":{"version":"0.0.1"},"title":"{{appTitle}}","description":"{{appDescription}}","resources":"resources.json","sourceTemplate":{"id":"@sap/generator-fiori:lrop","version":"1.8.4","toolsId":"49feae68-fecb-4dba-baab-11131d9b146a"},"dataSources":{"mainService":{"uri":"/sap/opu/odata/sap/ZC_PT028_REPORT_CDS/","type":"OData","settings":{"annotations":["ZC_PT028_REPORT_CDS_VAN","annotation"],"localUri":"localService/metadata.xml","odataVersion":"2.0"}},"ZC_PT028_REPORT_CDS_VAN":{"uri":"/sap/opu/odata/IWFND/CATALOGSERVICE;v=2/Annotations(TechnicalName=\'ZC_PT028_REPORT_CDS_VAN\',Version=\'0001\')/$value/","type":"ODataAnnotation","settings":{"localUri":"localService/ZC_PT028_REPORT_CDS_VAN.xml"}},"annotation":{"type":"ODataAnnotation","uri":"annotations/annotation.xml","settings":{"localUri":"annotations/annotation.xml"}}}},"sap.ui":{"technology":"UI5","icons":{"icon":"","favIcon":"","phone":"","phone@2":"","tablet":"","tablet@2":""},"deviceTypes":{"desktop":true,"tablet":true,"phone":true}},"sap.ui5":{"flexEnabled":true,"dependencies":{"minUI5Version":"1.104.0","libs":{"sap.m":{},"sap.ui.core":{},"sap.ushell":{},"sap.f":{},"sap.ui.comp":{},"sap.ui.generic.app":{},"sap.suite.ui.generic.template":{}}},"contentDensities":{"compact":true,"cozy":true},"models":{"i18n":{"type":"sap.ui.model.resource.ResourceModel","settings":{"bundleName":"zpt028.i18n.i18n"}},"":{"dataSource":"mainService","preload":true,"settings":{"defaultBindingMode":"TwoWay","defaultCountMode":"Inline","refreshAfterChange":false,"metadataUrlParams":{"sap-value-list":"all"}}},"@i18n":{"type":"sap.ui.model.resource.ResourceModel","uri":"i18n/i18n.properties"}},"resources":{"css":[]},"routing":{"config":{},"routes":[],"targets":{}},"extends":{"extensions":{"sap.ui.controllerExtensions":{"sap.suite.ui.generic.template.ListReport.view.ListReport":{"controllerName":"zpt028.ext.controller.ListReportExtension"},"sap.suite.ui.generic.template.ObjectPage.view.Details":{"controllerName":"zpt028.ext.controller.ObjectPageExtension","sap.ui.generic.app":{}}},"sap.ui.viewExtensions":{"sap.suite.ui.generic.template.ListReport.view.ListReport":{"SmartFilterBarControlConfigurationExtension|ZC_PT028_REPORT":{"className":"sap.ui.core.Fragment","fragmentName":"zpt028.ext.fragment.CustomFilter","type":"XML"}},"sap.suite.ui.generic.template.ObjectPage.view.Details":{"BeforeFacet|ZC_PT028_REPORT|WorkInfo":{"className":"sap.ui.core.Fragment","fragmentName":"zpt028.ext.fragment.Schedule","type":"XML","sap.ui.generic.app":{"title":"Schedule"}}}}}}},"sap.ui.generic.app":{"_version":"1.3.0","settings":{"forceGlobalRefresh":false,"objectPageHeaderType":"Dynamic","considerAnalyticalParameters":true,"showDraftToggle":false,"flexibleColumnLayout":{"defaultTwoColumnLayoutType":"TwoColumnsMidExpanded","defaultThreeColumnLayoutType":"ThreeColumnsMidExpanded"}},"pages":{"ListReport|ZC_PT028_REPORT":{"entitySet":"ZC_PT028_REPORT","component":{"name":"sap.suite.ui.generic.template.ListReport","list":true,"settings":{"condensedTableLayout":true,"smartVariantManagement":true,"enableTableFilterInPageVariant":true,"filterSettings":{"dateSettings":{"useDateRange":true}},"dataLoadSettings":{"loadDataOnAppLaunch":"always"}}},"pages":{"ObjectPage|ZC_PT028_REPORT":{"entitySet":"ZC_PT028_REPORT","defaultLayoutTypeIfExternalNavigation":"MidColumnFullScreen","component":{"name":"sap.suite.ui.generic.template.ObjectPage"}}}}}},"sap.fiori":{"registrationIds":[],"archeType":"transactional"}}',
	"zpt028/utils/locate-reuse-libs.js":'(function(e){var t=function(e,t){var n=["sap.apf","sap.base","sap.chart","sap.collaboration","sap.f","sap.fe","sap.fileviewer","sap.gantt","sap.landvisz","sap.m","sap.ndc","sap.ovp","sap.rules","sap.suite","sap.tnt","sap.ui","sap.uiext","sap.ushell","sap.uxap","sap.viz","sap.webanalytics","sap.zen"];Object.keys(e).forEach(function(e){if(!n.some(function(t){return e===t||e.startsWith(t+".")})){if(t.length>0){t=t+","+e}else{t=e}}});return t};var n=function(e){var n="";if(e){if(e["sap.ui5"]&&e["sap.ui5"].dependencies){if(e["sap.ui5"].dependencies.libs){n=t(e["sap.ui5"].dependencies.libs,n)}if(e["sap.ui5"].dependencies.components){n=t(e["sap.ui5"].dependencies.components,n)}}if(e["sap.ui5"]&&e["sap.ui5"].componentUsages){n=t(e["sap.ui5"].componentUsages,n)}}return n};var r=function(e){var t=e;return new Promise(function(r,a){$.ajax(t).done(function(e){r(n(e))}).fail(function(){a(new Error("Could not fetch manifest at \'"+e))})})};var a=function(e){if(e){Object.keys(e).forEach(function(t){var n=e[t];if(n&&n.dependencies){n.dependencies.forEach(function(e){if(e.url&&e.url.length>0&&e.type==="UI5LIB"){jQuery.sap.log.info("Registering Library "+e.componentId+" from server "+e.url);jQuery.sap.registerModulePath(e.componentId,e.url)}})}})}};e.registerComponentDependencyPaths=function(e){return r(e).then(function(e){if(e&&e.length>0){var t="/sap/bc/ui2/app_index/ui5_app_info?id="+e;var n=jQuery.sap.getUriParameters().get("sap-client");if(n&&n.length===3){t=t+"&sap-client="+n}return $.ajax(t).done(a)}})}})(sap);var scripts=document.getElementsByTagName("script");var currentScript=document.getElementById("locate-reuse-libs");if(!currentScript){currentScript=document.currentScript}var manifestUri=currentScript.getAttribute("data-sap-ui-manifest-uri");var componentName=currentScript.getAttribute("data-sap-ui-componentName");var useMockserver=currentScript.getAttribute("data-sap-ui-use-mockserver");var bundleResources=function(){jQuery.sap.require("jquery.sap.resources");var e=sap.ui.getCore().getConfiguration().getLanguage();var t=jQuery.sap.resources({url:"i18n/i18n.properties",locale:e});document.title=t.getText("appTitle")};sap.registerComponentDependencyPaths(manifestUri).catch(function(e){jQuery.sap.log.error(e)}).finally(function(){sap.ui.getCore().attachInit(bundleResources);if(componentName&&componentName.length>0){if(useMockserver&&useMockserver==="true"){sap.ui.getCore().attachInit(function(){sap.ui.require([componentName.replace(/\\./g,"/")+"/localService/mockserver"],function(e){e.init();sap.ushell.Container.createRenderer().placeAt("content")})})}else{sap.ui.require(["sap/ui/core/ComponentSupport"]);sap.ui.getCore().attachInit(bundleResources)}}else{sap.ui.getCore().attachInit(function(){sap.ushell.Container.createRenderer().placeAt("content")})}});sap.registerComponentDependencyPaths(manifestUri);'
}});