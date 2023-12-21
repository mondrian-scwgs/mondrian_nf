//
// Check input samplesheet and get read channels
//

// TODO: get rid of samplesheet check replace with json input check
// include { SAMPLESHEET_CHECK } from '../../modules/local/samplesheet_check'
import groovy.json.JsonSlurper

class Lane {
    Path fastq1
    Path fastq2
    String lane_id
    String flowcell_id
}

class Cell {
    String cell_id
    List<Lane> lanes
}

def parseJson(Path path) {
    def jsonSlurper = new JsonSlurper()
    def object = jsonSlurper.parse(path)

    def cellsList = object.fastq_files.collect { cellMap ->
        def lanes = cellMap.lanes.collect { laneMap ->
            new Lane(fastq1: file(laneMap.fastq1), fastq2: file(laneMap.fastq2), lane_id: laneMap.lane_id, flowcell_id: laneMap.flowcell_id)
        }
        new Cell(cell_id: cellMap.cell_id, lanes: lanes)
    }

    // Print each Cell object
    cellsList.each { cell ->
        println "Cell ID: ${cell.cell_id}"
        cell.lanes.each { lane ->
            println "  Lane ID: ${lane.lane_id}, Fastq1: ${lane.fastq1}, Fastq2: ${lane.fastq2}"
        }
    }

    return cellsList
}

process CELLS_CHECK {
    // tag "$samplesheet"
    // label 'process_single'

    // conda "conda-forge::python=3.8.3"
    // container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
    //     'https://depot.galaxyproject.org/singularity/python:3.8.3' :
    //     'biocontainers/python:3.8.3' }"

    input:
    path cells_json

    output:
    path 'cells.valid.json', emit: valid_cells_json
    path "versions.yml", emit: versions

    // when:
    // task.ext.when == null || task.ext.when

    script: // This script is bundled with the pipeline, in mondrian-scwgs/mondrian_nf/bin/
    """
    cp $cells_json cells.valid.json

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
    END_VERSIONS
    """
}

workflow INPUT_CHECK {
    take:
    cells_json // file: /path/to/cells.json

    main:
    CELLS_CHECK(cells_json)

    CELLS_CHECK.out.valid_cells_json
        .map { jsonFile -> parseJson(jsonFile) }
        .set { cells }

    emit:
    cells // channel TODO: [ val(meta), [ reads ] ]
    versions = CELLS_CHECK.out.versions // channel: [ versions.yml ]
}

// TODO: not relevent
// Function to get list of [ meta, [ fastq_1, fastq_2 ] ]
def create_cells_channel(List<Cell> cells) {
    // create meta map
    def meta = [:]
    meta.id         = row.sample
    meta.single_end = row.single_end.toBoolean()

    // add path(s) of the fastq file(s) to the meta map
    def fastq_meta = []
    if (!file(row.fastq_1).exists()) {
        exit 1, "ERROR: Please check input samplesheet -> Read 1 FastQ file does not exist!\n${row.fastq_1}"
    }
    if (meta.single_end) {
        fastq_meta = [ meta, [ file(row.fastq_1) ] ]
    } else {
        if (!file(row.fastq_2).exists()) {
            exit 1, "ERROR: Please check input samplesheet -> Read 2 FastQ file does not exist!\n${row.fastq_2}"
        }
        fastq_meta = [ meta, [ file(row.fastq_1), file(row.fastq_2) ] ]
    }
    return fastq_meta
}
