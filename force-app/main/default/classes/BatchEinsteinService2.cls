public without sharing class BatchEinsteinService2 implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {

	public String query;

	public String einsteinKPIId;
	public List<String> kpiIds;

	public Integer currentSAQL = 1;
	public Integer totalSAQL;

	public Boolean dailyBatchProcess = false;
	public Boolean rescheduleDailyBatchProcess = true;
	public Boolean bulkRefreshKPIsProcess = false;
	public Boolean individualEinsteinKPIProcess = false;

	public static String SessionId= System.UserInfo.getSessionId();
	public BatchEinsteinService2(String einsteinKPIId) {
		this.einsteinKPIId = einsteinKPIId;
		this.individualEinsteinKPIProcess = true;
	}

	public BatchEinsteinService2(List<String> kpiIds) {
		this.kpiIds = kpiIds;
		this.bulkRefreshKPIsProcess = true;

	}

	public BatchEinsteinService2(List<String> kpiIds, Integer currentSAQL) {
		this.kpiIds = kpiIds;
		this.currentSAQL = currentSAQL;
		this.bulkRefreshKPIsProcess = true;

	}

	public BatchEinsteinService2(String einsteinKPIId, Integer currentSAQL) {
		this.einsteinKPIId = einsteinKPIId;
		this.currentSAQL = currentSAQL;
		this.totalSAQL = null;

	}

	public BatchEinsteinService2() {
	}

	public Database.QueryLocator start(Database.BatchableContext BC){

		Date today = Date.today();



		if(query == null) {
			query = 'select Id, Name, KPI__r.Name, KPI_SAQL_1__c, KPI_SAQL_2__c, KPI_SAQL_3__c, KPI_SAQL_4__c, KPI_SAQL_5__c, APIName__c, KPI_Level_1__c, KPI_Level_2__c, KPI_Level_3__c, KPI_Level_4__c, KPI_Level_5__c, ';
			query += ' KPI__c, Data_Sets__c, KPILookupKey1__c, KPILookupKey2__c, KPILookupKey3__c, KPILookupKey4__c, KPILookupKey5__c, ActualObjectiveComparator__c, TotalSAQLsToExecute__c, KPI__r.Category__c, KPI__r.SubCategory__c ';
			query += ' , RecordType.DeveloperName from EinsteinKPI__c where Active__c = true ';

			if(dailyBatchProcess) {
				query += ' and (NextRunDate__c = null or NextRunDate__c <= :today)';
				query += ' limit 1 ';
			}
			else if(bulkRefreshKPIsProcess) {
				query += 'and KPI__c in :kpiIds and TotalSAQLsToExecute__c >= :currentSAQL';
			}
			else if(individualEinsteinKPIProcess) {
				query += 'and Id = :einsteinKPIId';
			}
		}

		return Database.getQueryLocator(query);
	}

	//public static

	public void processAdminEinsteinKPIs(EinsteinKPI__c einsteinKPI) {
		System.debug(LoggingLevel.ERROR, einsteinKPI.Name);
		System.debug(LoggingLevel.ERROR, einsteinKPI.KPI__r.Name);

		einsteinKPIId = einsteinKPI.Id;
		totalSAQL = Integer.valueOf(einsteinKPI.TotalSAQLsToExecute__c);
		System.debug(LoggingLevel.ERROR, einsteinKPI.TotalSAQLsToExecute__c);
		System.debug(LoggingLevel.ERROR, totalSAQL);

		String kpiSAQL = EinsteinService.getCurrentRunSAQLFieldValue(einsteinKPI, currentSAQL); // 1
		String kpiRunLevel = EinsteinService.getCurrentRunLevelFieldValue(einsteinKPI, currentSAQL);
		String kpiLookupKey = EinsteinService.getCurrentRunLookupKeyFieldValue(einsteinKPI, currentSAQL);

		Map<String, EinsteinService.DataSetResult> dataSetResultMap = EinsteinService.getDataSetsLatestVersions();
		String updatedSAQLQuery = EinsteinService.buildSAQLQueryForLatestVersion(kpiSAQL, dataSetResultMap) ;
		List<Object> records = EinsteinService.retrieveQueryResultRecords(updatedSAQLQuery);

		Map<String, List<EinsteinKPIMapping__c>> mapOfEinsteinMappings = EinsteinService.getKPIFieldMappings(new Set<String>{einsteinKPI.Id}, currentSAQL);

		List<EinsteinKPIDetail__c> sfKPIDetails = new List<EinsteinKPIDetail__c>();
		System.debug('**************************** record ****************************');

		for(Object record:records) {
			System.debug(record);
			Map<String,Object> data = (Map<String,Object>)record;
			EinsteinKPIDetail__c sfKPIDetail = new EinsteinKPIDetail__c(EinsteinKPI__c = einsteinKPI.Id);
			sfKPIDetail.DetailKey__c = einsteinKPI.Id;
			if(mapOfEinsteinMappings.containskey(einsteinKPI.Id)) {
				for(EinsteinKPIMapping__c mapping:mapOfEinsteinMappings.get(einsteinKPI.Id)) {
					if(mapping.Type__c == 'Percent' || mapping.Type__c == 'Number' || mapping.Type__c == 'Currency') {

					}
					else {
						sfKPIDetail.put(mapping.Object_Field__c, data.get(mapping.KPI_Field__c));
					}
				}
			}
			sfKPIDetails.add(sfKPIDetail);
		}

		System.debug(LoggingLevel.ERROR, sfKPIDetails);
		if(!sfKPIDetails.isEmpty() && !Test.isRunningTest()) {
			upsert sfKPIDetails DetailKey__c;
		}
	}

	private String handleStringReplaceForSAQL(String sAQLQuery) {
		ReportingPeriodSetting__c setting = ReportingPeriodSetting__c.getInstance('reporting_period');
		if(setting != null && setting.Value__c != null) {
			return sAQLQuery.replaceAll('#reporting_period#', setting.Value__c);
		}
		return '202102';
	}

	public void execute(Database.BatchableContext BC, List<EinsteinKPI__c> einsteinKPIs) {


		if(einsteinKPIs[0].RecordType.DeveloperName == 'Admin') {
			processAdminEinsteinKPIs(einsteinKPIs[0]);
		}
		else {
			System.debug(LoggingLevel.ERROR, einsteinKPIs[0].Name);
			System.debug(LoggingLevel.ERROR, einsteinKPIs[0].KPI__r.Name);

			// G-Stock Age Over 365 days
			einsteinKPIId = einsteinKPIs[0].Id;
			// 1
			totalSAQL = Integer.valueOf(einsteinKPIs[0].TotalSAQLsToExecute__c);
			System.debug(LoggingLevel.ERROR, einsteinKPIs[0].TotalSAQLsToExecute__c);
			System.debug(LoggingLevel.ERROR, totalSAQL);

			String kpiSAQL = EinsteinService.getCurrentRunSAQLFieldValue(einsteinKPIs[0], currentSAQL);
			String kpiRunLevel = EinsteinService.getCurrentRunLevelFieldValue(einsteinKPIs[0], currentSAQL);
			String kpiLookupKey = EinsteinService.getCurrentRunLookupKeyFieldValue(einsteinKPIs[0], currentSAQL);
			system.debug(' i am here');
			Map<String, EinsteinService.DataSetResult> dataSetResultMap = EinsteinService.getDataSetsLatestVersions();
			String updatedSAQLQuery = '';
			updatedSAQLQuery = EinsteinService.buildSAQLQueryForLatestVersion(kpiSAQL, dataSetResultMap) ;
			updatedSAQLQuery = handleStringReplaceForSAQL(updatedSAQLQuery);
			List<Object> records = EinsteinService.retrieveQueryResultRecords(updatedSAQLQuery);

			Map<String, Object> lookupKeyObjectMap = new Map<String, Object>();
			map<string,List<Object>> gridDataMap = new map<string,List<Object>>();
			for(Object record:records) {
				List<Object> gridDataDetail = new List<Object>();

				Map<String,Object> data = (Map<String,Object>)record;
				if(lookupKeyObjectMap.containskey((String)data.get(kpiLookupKey)) && einsteinKPIs[0].RecordType.DeveloperName=='Grid_Level_Detail' ){
					gridDataDetail = gridDataMap.get((String)data.get(kpiLookupKey));
					gridDataDetail.add(record);
					gridDataMap.put((String)data.get(kpiLookupKey),gridDataDetail);
				}else{
					lookupKeyObjectMap.put((String)data.get(kpiLookupKey), record);
					gridDataDetail.add(record);
					gridDataMap.put((String)data.get(kpiLookupKey),gridDataDetail);
				}
				system.debug('record is '+ record);
				system.debug('lookupKeyObjectMap ' + lookupKeyObjectMap);
			}

			Map<String, List<SObject>> lookupKeyAccountMap = EinsteinService.getLookupKeyAccountMap(lookupKeyObjectMap.keySet(), kpiRunLevel);
			Map<String, List<EinsteinKPIMapping__c>> mapOfEinsteinMappings = EinsteinService.getKPIFieldMappings(new Set<String>{einsteinKPIs[0].Id}, currentSAQL);
			List<EinsteinKPIDetail__c> sfKPIDetails = new List<EinsteinKPIDetail__c>();

			System.debug(LoggingLevel.ERROR, lookupKeyObjectMap);
			for(String lookupKey:lookupKeyObjectMap.keyset()) {

				//System.debug(LoggingLevel.ERROR, lookupKey);
				if(lookupKeyAccountMap.containsKey(lookupKey)) {
					for(SObject objectRecord:lookupKeyAccountMap.get(lookupKey)) {
						System.debug(LoggingLevel.ERROR, (String)objectRecord.get('Name'));
						//Account account = lookupKeyAccountMap.get(lookupKey).Id;

						Map<String,Object> data = (Map<String,Object>)lookupKeyObjectMap.get(lookupKey);
						//String uniqueKey = sfKPIRecord.Id + '-' + accountId;
						system.debug('size of data ' + data.size()  );
						EinsteinKPIDetail__c sfKPIDetail = new EinsteinKPIDetail__c(EinsteinKPI__c = einsteinKPIs[0].Id );
						if(kpiRunLevel == 'Dealer') {
							sfKPIDetail.Account__c = (Id)objectRecord.get('Id');
							sfKPIDetail.DealerCode__c = (String)objectRecord.get('DealerCode__c');
						}
						else if(kpiRunLevel == 'Region') {
							sfKPIDetail.Region__c = (Id)objectRecord.get('Id');
						}
						else if(kpiRunLevel == 'Sales District') {
							sfKPIDetail.District__c = (Id)objectRecord.get('Id');
						}

						String keyValue = '';

						Boolean foundKeyValue = false;
						system.debug('record type ' + einsteinKPIs[0].RecordType.DeveloperName);
						if(einsteinKPIs[0].RecordType.DeveloperName!='Grid_Level_Detail'){
							if(mapOfEinsteinMappings.containskey(einsteinKPIs[0].Id)) {


								for(EinsteinKPIMapping__c mapping:mapOfEinsteinMappings.get(einsteinKPIs[0].Id)) {

									if(mapping.Type__c == 'Percent' || mapping.Type__c == 'Number' || mapping.Type__c == 'Currency') {
										Decimal value = null;
										if(mapping.Type__c == 'Percent') {
											if(data.containsKey(mapping.KPI_Field__c) && data.get(mapping.KPI_Field__c) != null) {
												if(mapping.MultiplyBy100ForPercent__c) {
													value = (Decimal)data.get(mapping.KPI_Field__c) * 100;
												}
												else {
													value = (Decimal)data.get(mapping.KPI_Field__c);
												}
												value = value.setScale(2);
											}
											else if(mapping.Show_fields_when_data_not_available__c){
												value = 0;
											}
										}
										else {
											value = (Decimal)data.get(mapping.KPI_Field__c);
											if(value != null) {
												value = value.setScale(2);
											}
											else if(mapping.Show_fields_when_data_not_available__c){
												value = 0;
											}
										}
										System.debug(LoggingLevel.ERROR, mapping.Object_Field__c);
										System.debug(LoggingLevel.ERROR, value);
										sfKPIDetail.put(mapping.Object_Field__c, value);
										System.debug(LoggingLevel.ERROR, 'keyvalue' + keyValue);
										System.debug(LoggingLevel.ERROR, 'keyvalue');
										System.debug(LoggingLevel.ERROR, mapping.Key_Value__c);
										if(mapping.Key_Value__c) {
											if(keyValue != '') {
												keyValue += '\n';
											}
											foundKeyValue = true;
											if(mapping.IncludeLabelInKeyValue__c) {
												keyValue += mapping.KPIFieldDescription__c + ': ';
											}
											System.debug(LoggingLevel.ERROR, mapping.Key_Value__c);
											if(mapping.Type__c == 'Percent' && value != NULL){
												keyValue += getNumericaStringValue(value) + '%';
											}
											else if(mapping.Type__c == 'Currency' && value != NULL) {
												keyValue += '$' + getNumericaStringValue(value);
											}
											else {
												if(value != NULL) {
													keyValue += String.valueOf(value);
												}
												else if(mapping.Show_fields_when_data_not_available__c){
													keyValue += '0';
												}

											}
											System.debug(LoggingLevel.ERROR, keyvalue);
											System.debug(LoggingLevel.ERROR, mapping.Type__c);
										}
									}
									else {
										System.debug(LoggingLevel.ERROR, mapping.Object_Field__c);
										System.debug(LoggingLevel.ERROR, data.get(mapping.KPI_Field__c));
										sfKPIDetail.put(mapping.Object_Field__c, data.get(mapping.KPI_Field__c));
									}
									if(mapping.Object_Field__c.startsWith('Label')) {
										String[] fieldAPIMakeup = mapping.Object_Field__c.split('_');

										if(!String.isBlank(mapping.KPIFieldDescription__c)) {
											sfKPIDetail.put(fieldAPIMakeup[0] + '__c', mapping.KPIFieldDescription__c);
										}
										else {
											sfKPIDetail.put(fieldAPIMakeup[0] + '__c', mapping.KPI_Field__c);
										}
									}
								}
							} }
						else{
							/*code by Neeraj DPM-144 for Kpi dashboard grid level data
									system.debug('i am here');
                                    Dashboard_Table_Grid_Column__c DTGC = Dashboard_Table_Grid_Column__c.getValues(einsteinKPIs[0].KPI__r.Name);
                                   
                                    String gridData='<table><tr>';
                                   integer count=0;
                                    if(DTGC!=null){
                                  String[] cols=(DTGC.Column_names__c).remove('\'').split(',');
                                    
                                    
                                    for(string key: cols){
                                            if(!key.endsWithIgnoreCase('dealer_cd')||!key.endsWithIgnoreCase('inventory_dealer_cd') )
                                        gridData+='<th>'+key+'</th>';
                                    }
                                    gridData+='</tr>';
                                        for(object data1 : gridDataMap.get(lookupKey)){
                                             gridData+='<tr>';
                                            Map<String,Object> data2 = (Map<String,Object>)data1;
                                        for(string key: cols){
                                             if(!key.endsWithIgnoreCase('dealer_cd')||!key.endsWithIgnoreCase('inventory_dealer_cd') )
                                            gridData +='<td>'+(data2.get(key))+'</td>';
                                        }
                                            gridData+='</tr>';
                                        }
                                    gridData+='</table>';
									 sfKPIDetail.Dashboard_table_record__c=gridData;
                                    } */ }

						sfKPIDetail.DetailKey__c = einsteinKPIs[0].Id + '-' + (Id)objectRecord.get('Id');

						sfKPIDetail.KPI__c = einsteinKPIs[0].KPI__c;
						sfKPIDetail.LastCalculationDate__c = Datetime.now();
						sfKPIDetail.ApexJobId__c = bc != null ? bc.getJobId() : null;
						sfKPIDetail.Category__c = einsteinKPIs[0].KPI__r.Category__c;
						sfKPIDetail.SubCategory__c = einsteinKPIs[0].KPI__r.SubCategory__c;

						if(foundKeyValue) {
							System.debug(LoggingLevel.ERROR, keyValue);
							String currentKeyValueField = 'Key_Value_' + currentSAQL + '__c';

							if(currentSAQL == 1) {
								sfKPIDetail.Key_Value_2__c = '';
								sfKPIDetail.Key_Value_3__c = '';
								sfKPIDetail.Key_Value_4__c = '';
								sfKPIDetail.Key_Value_5__c = '';
							}
							sfKPIDetail.put(currentKeyValueField, keyValue);
						}

						System.debug(LoggingLevel.ERROR, sfKPIDetail);
						sfKPIDetails.add(sfKPIDetail);
					}
				}
			}

			if(!sfKPIDetails.isEmpty() && !Test.isRunningTest()) {
				upsert sfKPIDetails DetailKey__c;
			}
		}
	}

	private String getNumericaStringValue(Decimal x){
		String y = String.valueOf(x);
		String z = '.';
		if(y.contains(',')) z = ',';
		y = y.substring(0, y.indexOf(z));
		if(x - Decimal.valueOf(y) == 0)
			return String.valueOf(x.format()) + z + '00';
		else return String.valueOf(x.format());
	}

	public void finish(Database.BatchableContext BC){
		System.debug(LoggingLevel.ERROR, 'Current SAQL: ' + currentSAQL);
		System.debug(LoggingLevel.ERROR, 'Total SAQL: ' + totalSAQL);

		if(individualEinsteinKPIProcess) {
			if(currentSAQL < totalSAQL ) {
				BatchEinsteinService2 batchEinsteinJob = new BatchEinsteinService2(einsteinKPIId, currentSAQL + 1);
				batchEinsteinJob.individualEinsteinKPIProcess = true;
				batchEinsteinJob.bulkRefreshKPIsProcess = false;
				if(!Test.isRunningTest()) {
					Database.executeBatch(batchEinsteinJob, 1);
				}
			}
			else {

				BatchCheckThesholdsForEinsteinKPIs batchCalculateThresholds = new BatchCheckThesholdsForEinsteinKPIs(einsteinKPIId);
				batchCalculateThresholds.dailyBatchProcess = false;
				Database.executeBatch(batchCalculateThresholds, 200);
			}
		}
		else if(dailyBatchProcess) {
			if(totalSAQL == null && rescheduleDailyBatchProcess) {
				// 2023-09-21 6am -> 3am
				String sched = '0 0 03 * * ? *';
				ScheduleBatchEinsteinService scheduleBatchEninsteinService = new ScheduleBatchEinsteinService();
				if(!Test.isRunningTest()) {
					System.schedule('Daily Batch Einstein Service', sched, scheduleBatchEninsteinService);
				}
			}
			else if(currentSAQL < totalSAQL) {
				BatchEinsteinService2 batchEinsteinJob = new BatchEinsteinService2(einsteinKPIId, currentSAQL + 1);
				batchEinsteinJob.dailyBatchProcess = true;
				batchEinsteinJob.rescheduleDailyBatchProcess = rescheduleDailyBatchProcess;
				if(!Test.isRunningTest()) {
					Database.executeBatch(batchEinsteinJob, 1);
				}
			}
			else if(currentSAQL == totalSAQL) {
				Date tomorrow = Date.today().addDays(1);
				EinsteinKPI__c kpiToUpdateNextRunDate = new EinsteinKPI__c(Id = einsteinKPIId, NextRunDate__c = tomorrow);
				update kpiToUpdateNextRunDate;

				BatchCheckThesholdsForEinsteinKPIs batchCalculateThresholds = new BatchCheckThesholdsForEinsteinKPIs(einsteinKPIId);
				batchCalculateThresholds.dailyBatchProcess = true;
				batchCalculateThresholds.rescheduleDailyBatchProcess = rescheduleDailyBatchProcess;
				Database.executeBatch(batchCalculateThresholds, 200);
			}
		}
		else if (bulkRefreshKPIsProcess) {
			if(currentSAQL < 5 ) {
				BatchEinsteinService2 batchEinsteinJob = new BatchEinsteinService2(kpiIds, currentSAQL + 1);
				batchEinsteinJob.bulkRefreshKPIsProcess = true;
				if(!Test.isRunningTest()) {
					Database.executeBatch(batchEinsteinJob, 1);
				}
			}
			else if(currentSAQL == 5) {
				BatchProcessActionPlanSnapshots actionPlanSnapshotBatch = new BatchProcessActionPlanSnapshots(kpiIds);
				Database.executeBatch(actionPlanSnapshotBatch, 50);
			}
		}
	}
}