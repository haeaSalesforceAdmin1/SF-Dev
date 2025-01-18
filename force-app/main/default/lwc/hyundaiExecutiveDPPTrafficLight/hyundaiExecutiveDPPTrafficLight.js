/**
 * Created by User on 2024-02-29.
 */

import { LightningElement, track, api, wire } from 'lwc';

export default class HyundaiExecutiveDPPTrafficLight extends LightningElement {

    @api results;
    @api dpb;
    @api type;

    get stringResults() {
        return 'results: ' + JSON.stringify(this.results);
    }

    edit(e, c, v) {
        var contact = this.results;
        for (var i = 0; i < contact.length; i++) { 	
            var x = 0;
            if (v == 'r3') x = Number(contact[i].r3);
            if (v == 'r12') x = Number(contact[i].r12);
            if (v == 'mtd') x = Number(contact[i].mtd);
            if (v == 'qtd') x = Number(contact[i].qtd);
            if (v == 'ytd') x = Number(contact[i].ytd);
            if (v == 'kts_achv_cnt') x = Number(contact[i].kts_achv_cnt);

            if (contact[i].name == e && e == 'dpb') {
                if (c == 'red') return (x < 90) ? 'light-on-red' : 'light-off';
                if (c == 'yellow') return (x >= 90 && x < 100) ? 'light-on-yellow' : 'light-off';
                if (c == 'green') return (x >= 100) ? 'light-on-green' : 'light-off';
            }

            if (contact[i].name == e && e == 'cuv_obj') {
                if (c == 'red') return (x < 90) ? 'light-on-red' : 'light-off';
                if (c == 'yellow') return (x >= 90 && x < 100) ? 'light-on-yellow' : 'light-off';
                if (c == 'green') return (x >= 100) ? 'light-on-green' : 'light-off';
            }

            if (contact[i].name == e && e == 'cuv_nation_pen') {
                var r = contact[6].ytd != null ? contact[6].ytd : 0;
                if (c == 'red') return (r < (x - 2)) ? 'light-on-red' : 'light-off';
                if (c == 'yellow') return (r >= (x - 2) && r < x) ? 'light-on-yellow' : 'light-off';
                if (c == 'green') return (r >= x) ? 'light-on-green' : 'light-off';
            }

            if (contact[i].name == e && e == 'recall_on_drive_completion') {
                if (c == 'red') return (x < 70) ? 'light-on-red' : 'light-off';
                if (c == 'yellow') return (x >= 70 && x < 95) ? 'light-on-yellow' : 'light-off';
                if (c == 'green') return (x >= 95) ? 'light-on-green' : 'light-off';
            }

            if (contact[i].name == e && e == 'total_parts') {
                if (c == 'red') return (x < 95) ? 'light-on-red' : 'light-off';
                if (c == 'yellow') return (x >= 95 && x < 100) ? 'light-on-yellow' : 'light-off';
                if (c == 'green') return (x >= 100) ? 'light-on-green' : 'light-off';
            }

            if (contact[i].name == e && e == 'competitive_parts_sales') {
                if (c == 'red') return (x < 95) ? 'light-on-red' : 'light-off';
                if (c == 'yellow') return (x >= 95 && x < 100) ? 'light-on-yellow' : 'light-off';
                if (c == 'green') return (x >= 100) ? 'light-on-green' : 'light-off';
            }

            if (contact[i].name == e && e == 'retail_experience_sales') {
                if (c == 'red') return (x < 4) ? 'light-on-red' : 'light-off';
                if (c == 'yellow') return (x == 4) ? 'light-on-yellow' : 'light-off';
                if (c == 'green') return (x >= 5) ? 'light-on-green' : 'light-off';
            }

            if (contact[i].name == e && e == 'retail_experience_service') {
                if (c == 'red') return (x < 4) ? 'light-on-red' : 'light-off';
                if (c == 'yellow') return (x == 4) ? 'light-on-yellow' : 'light-off';
                if (c == 'green') return (x >= 5) ? 'light-on-green' : 'light-off';
            }

            if (contact[i].name == e && e == 'sales_efficiency') {
                if (c == 'red') return (x < 90) ? 'light-on-red' : 'light-off';
                if (c == 'yellow') return (x >= 90 && x < 100) ? 'light-on-yellow' : 'light-off';
                if (c == 'green') return (x >= 100) ? 'light-on-green' : 'light-off';
            }
        }
        return 'light-off';
    }

    get dpb_mtd_red() { return this.edit('dpb', 'red', 'mtd') }
    get dpb_mtd_yellow() { return this.edit('dpb', 'yellow', 'mtd') }
    get dpb_mtd_green() { return this.edit('dpb', 'green', 'mtd') }

    get dpb_qtd_red() { return this.edit('dpb', 'red', 'qtd') }
    get dpb_qtd_yellow() { return this.edit('dpb', 'yellow', 'qtd') }
    get dpb_qtd_green() { return this.edit('dpb', 'green', 'qtd') }

    get dpb_ytd_red() { return this.edit('dpb', 'red', 'ytd') }
    get dpb_ytd_yellow() { return this.edit('dpb', 'yellow', 'ytd') }
    get dpb_ytd_green() { return this.edit('dpb', 'green', 'ytd') }

    get hcuv_obj_red() { return this.edit('cuv_obj', 'red', 'ytd') }
    get hcuv_obj_yellow() { return this.edit('cuv_obj', 'yellow', 'ytd') }
    get hcuv_obj_green() { return this.edit('cuv_obj', 'green', 'ytd') }

    get hcuv_pen_red() { return this.edit('cuv_nation_pen', 'red', 'ytd') }
    get hcuv_pen_yellow() { return this.edit('cuv_nation_pen', 'yellow', 'ytd') }
    get hcuv_pen_green() { return this.edit('cuv_nation_pen', 'green', 'ytd') }

    get sales_efficiency_r3_red() { return this.edit('sales_efficiency', 'red', 'r3') }
    get sales_efficiency_r3_yellow() { return this.edit('sales_efficiency', 'yellow', 'r3') }
    get sales_efficiency_r3_green() { return this.edit('sales_efficiency', 'green', 'r3') }

    get sales_efficiency_r12_red() { return this.edit('sales_efficiency', 'red', 'r12') }
    get sales_efficiency_r12_yellow() { return this.edit('sales_efficiency', 'yellow', 'r12') }
    get sales_efficiency_r12_green() { return this.edit('sales_efficiency', 'green', 'r12') }

    get sales_efficiency_ytd_red() { return this.edit('sales_efficiency', 'red', 'ytd') }
    get sales_efficiency_ytd_yellow() { return this.edit('sales_efficiency', 'yellow', 'ytd') }
    get sales_efficiency_ytd_green() { return this.edit('sales_efficiency', 'green', 'ytd') }

    get retail_experience_sales_red() { return this.edit('retail_experience_sales', 'red', 'kts_achv_cnt') }
    get retail_experience_sales_yellow() { return this.edit('retail_experience_sales', 'yellow', 'kts_achv_cnt') }
    get retail_experience_sales_green() { return this.edit('retail_experience_sales', 'green', 'kts_achv_cnt') }

    get retail_experience_service_red() { return this.edit('retail_experience_service', 'red', 'kts_achv_cnt') }
    get retail_experience_service_yellow() { return this.edit('retail_experience_service', 'yellow', 'kts_achv_cnt') }
    get retail_experience_service_green() { return this.edit('retail_experience_service', 'green', 'kts_achv_cnt') }

    get recall_on_drive_completion_mtd_red() { return this.edit('recall_on_drive_completion', 'red', 'mtd') }
    get recall_on_drive_completion_mtd_yellow() { return this.edit('recall_on_drive_completion', 'yellow', 'mtd') }
    get recall_on_drive_completion_mtd_green() { return this.edit('recall_on_drive_completion', 'green', 'mtd') }

    get recall_on_drive_completion_qtd_red() { return this.edit('recall_on_drive_completion', 'red', 'qtd') }
    get recall_on_drive_completion_qtd_yellow() { return this.edit('recall_on_drive_completion', 'yellow', 'qtd') }
    get recall_on_drive_completion_qtd_green() { return this.edit('recall_on_drive_completion', 'green', 'qtd') }

    get recall_on_drive_completion_ytd_red() { return this.edit('recall_on_drive_completion', 'red', 'ytd') }
    get recall_on_drive_completion_ytd_yellow() { return this.edit('recall_on_drive_completion', 'yellow', 'ytd') }
    get recall_on_drive_completion_ytd_green() { return this.edit('recall_on_drive_completion', 'green', 'ytd') }

    get total_parts_mtd_red() { return this.edit('total_parts', 'red', 'mtd') }
    get total_parts_mtd_yellow() { return this.edit('total_parts', 'yellow', 'mtd') }
    get total_parts_mtd_green() { return this.edit('total_parts', 'green', 'mtd') }

    get total_parts_qtd_red() { return this.edit('total_parts', 'red', 'qtd') }
    get total_parts_qtd_yellow() { return this.edit('total_parts', 'yellow', 'qtd') }
    get total_parts_qtd_green() { return this.edit('total_parts', 'green', 'qtd') }

    get total_parts_ytd_red() { return this.edit('total_parts', 'red', 'ytd') }
    get total_parts_ytd_yellow() { return this.edit('total_parts', 'yellow', 'ytd') }
    get total_parts_ytd_green() { return this.edit('total_parts', 'green', 'ytd') }

    get comp_parts_sales_mtd_red() { return this.edit('competitive_parts_sales', 'red', 'mtd') }
    get comp_parts_sales_mtd_yellow() { return this.edit('competitive_parts_sales', 'yellow', 'mtd') }
    get comp_parts_sales_mtd_green() { return this.edit('competitive_parts_sales', 'green', 'mtd') }

    get comp_parts_sales_qtd_red() { return this.edit('competitive_parts_sales', 'red', 'qtd') }
    get comp_parts_sales_qtd_yellow() { return this.edit('competitive_parts_sales', 'yellow', 'qtd') }
    get comp_parts_sales_qtd_green() { return this.edit('competitive_parts_sales', 'green', 'qtd') }

    get comp_parts_sales_ytd_red() { return this.edit('competitive_parts_sales', 'red', 'ytd') }
    get comp_parts_sales_ytd_yellow() { return this.edit('competitive_parts_sales', 'yellow', 'ytd') }
    get comp_parts_sales_ytd_green() { return this.edit('competitive_parts_sales', 'green', 'ytd') }
}