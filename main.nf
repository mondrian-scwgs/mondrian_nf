#!/usr/bin/env nextflow

import groovy.json.JsonBuilder
// Declare syntax version
nextflow.enable.dsl=2







if (params.mode == 'qc'){
    include { MONDRIAN_QC_PIPELINE } from './workflows/mondrian_qc'
}

// if (params.mode == 'inferhaps'){
//     include { MONDRIAN_INFERHAPS_PIPELINE } from './workflows/mondrian_inferhaps'
//     workflow INFERHAPS {
//         MONDRIAN_INFERHAPS_PIPELINE ()
//     }
// }
//
// WORKFLOW: Run main demultiplex analysis pipeline
//



/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Execute a single named workflow for the pipeline
//
workflow {
    switch (params.mode) {
      case {'qc'}:
        MONDRIAN_QC_PIPELINE()
    }
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
