#!/usr/bin/env nextflow

import groovy.json.JsonBuilder
// Declare syntax version
nextflow.enable.dsl=2

if (params.mode == "qc") {
    include { MONDRIAN_QC_PIPELINE } from './workflows/mondrian_qc'
} else if (params.mode == "inferhaps") {
    include { MONDRIAN_INFERHAPS_PIPELINE } from './workflows/mondrian_inferhaps'
} else if (params.mode == "counthaps") {
    include { MONDRIAN_COUNTHAPS_PIPELINE } from './workflows/mondrian_counthaps'
} else if (params.mode == "snv_genotyping") {
    include { MONDRIAN_SNVGENOTYPING_PIPELINE } from './workflows/mondrian_snvgenotyping'
} else if (params.mode == "normalizer") {
    include { MONDRIAN_NORMALIZER_PIPELINE } from './workflows/mondrian_normalizer'
} else if (params.mode == "breakpoint") {
    include { MONDRIAN_BREAKPOINT_PIPELINE } from './workflows/mondrian_breakpoint'
} else if (params.mode == "variant") {
    include { MONDRIAN_VARIANT_PIPELINE } from './workflows/mondrian_variant'
}


workflow MONDRIAN {
    if(params.mode == "qc") {
        MONDRIAN_QC_PIPELINE ()
    }
    else if(params.mode == "inferhaps") {
        MONDRIAN_INFERHAPS_PIPELINE ()
    }
    else if(params.mode == "counthaps") {
        MONDRIAN_COUNTHAPS_PIPELINE ()
    }
    else if(params.mode == "snv_genotyping") {
        MONDRIAN_SNVGENOTYPING_PIPELINE ()
    }
    else if(params.mode == "normalizer") {
        MONDRIAN_NORMALIZER_PIPELINE ()
    }
    else if(params.mode == "breakpoint") {
        MONDRIAN_BREAKPOINT_PIPELINE ()
    }
    else if(params.mode == "variant") {
        MONDRIAN_VARIANT_PIPELINE ()
    }
}


/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN ALL WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

//
// WORKFLOW: Execute a single named workflow for the pipeline
//
workflow {
    MONDRIAN()
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
