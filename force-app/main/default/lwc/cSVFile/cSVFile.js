import {  LightningElement, api, wire, track} from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import excelparselib from '@salesforce/resourceUrl/excelparselib';
import sendJson from "@salesforce/apex/LWCimportFile.sendJson";



class ExcelToJSON {
    
    

    constructor() {
       
        this.parseExcel = function (file,obj) {
            var reader = new FileReader();
            reader.onload = function (e) {
                var data = e.target.result;
                var workbook = XLSX.read(data, {
                    type: 'binary'
                });
                workbook.SheetNames.forEach(function (sheetName) {
                    // Here is your object
                    var XL_row_object = XLSX.utils.sheet_to_row_object_array(workbook.Sheets[sheetName]);
                    var json_object = JSON.stringify(XL_row_object).replace(/"\s+|\s+"/g,'"');
                    json_object = json_object.replace(new RegExp("Serial#s", 'g'),'Serials');
                    var jsonobj='{"case":'+json_object+'}';
                    console.log(jsonobj);
                    console.log(JSON.parse(json_object));
                    var arr=JSON.parse(json_object);

                    //send the json string into controller SendJson method
                    sendJson({json: jsonobj})
                                    .then(result => {
                                       //split the message and csv content
                                       var msg=result.split(';');
                                        obj.messagefromcontroller=msg[0];
                                        console.log(msg);
                                        var filedown = obj.template.querySelector('[data-id="report"]');
                                        filedown.href = 'data:text/csv;charset=utf-8,' + encodeURI(msg[1]);
                                        filedown.target = '_blank';
                                        filedown.style='block';
                                        filedown.download = 'report.csv';
                                        return result;
                                    })
                                    .catch(error => {
                                        console.log(error);
                                        var errors = error;

                                    });
                });
            };
            reader.onerror = function (ex) {
                console.log(ex);
            };
            reader.readAsBinaryString(file);
        };
    }
}

export default class cSVFile extends LightningElement {

    @track
    messagefromcontroller ='';
    
    //libraries used for excel parser to work
    renderedCallback() {
        
        Promise.all([
            loadScript(this, excelparselib + '/jquery.min.js'),
            loadScript(this, excelparselib + '/jszip.js'),
            loadScript(this, excelparselib + '/xlsx.js'),
        ])
            .then(() => {
                console.log('Files loaded.');
            })
            .catch(error => {
                console.log(error.body.message);
            });
    }

     Upload() {
        this.messagefromcontroller="Processing..Please wait.";
        //get file from the dom element
        var fileUpload = this.template.querySelector('[data-id="file"]');
        console.log(fileUpload.files[0]);
        var xl2json = new ExcelToJSON();
        var msg=xl2json.parseExcel(fileUpload.files[0],this);
        
     }

   
      
}