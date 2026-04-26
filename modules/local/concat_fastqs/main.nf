process CONCAT_FASTQS {
    tag "$sample_id"
    label 'process_low'

    input:
    path(tagged_r1_files)
    path(tagged_r2_files)
    val(sample_id)

    output:
    tuple val(sample_id), path("${sample_id}_merged_R1.fastq.gz"), path("${sample_id}_merged_R2.fastq.gz")

    script:
    """
    set -e

    # Convert space-separated file lists into sorted arrays
    r1_files=( ${tagged_r1_files} )
    r2_files=( ${tagged_r2_files} )

    # Verify same number of R1 and R2 files
    if [[ \${#r1_files[@]} -ne \${#r2_files[@]} ]]; then
        echo "ERROR: Number of R1 files (\${#r1_files[@]}) does not match R2 files (\${#r2_files[@]})" >&2
        exit 1
    fi

    # Sort both arrays
    IFS=\$'\\n' sorted_r1=(\$(sort <<<"\${r1_files[*]}"))
    IFS=\$'\\n' sorted_r2=(\$(sort <<<"\${r2_files[*]}"))
    unset IFS

    # Verify that prefixes match between corresponding R1 and R2 files
    echo "Validating R1/R2 file pairing..."
    for i in "\${!sorted_r1[@]}"; do
        r1_file="\${sorted_r1[\$i]}"
        r2_file="\${sorted_r2[\$i]}"

        # Extract prefix by stripping the exact known suffix (no wildcards)
        prefix_r1="\${r1_file%_R1.tagged.fastq.gz}"
        prefix_r2="\${r2_file%_R2.tagged.fastq.gz}"

        if [[ "\$prefix_r1" != "\$prefix_r2" ]]; then
            echo "ERROR: Prefix mismatch at position \$i" >&2
            echo "  R1: \$r1_file (prefix: \$prefix_r1)" >&2
            echo "  R2: \$r2_file (prefix: \$prefix_r2)" >&2
            exit 1
        fi
        echo "  [\$(( i+1 ))] \$prefix_r1: \$r1_file + \$r2_file"
    done

    # Concatenate in sorted order
    echo "Concatenating files..."
    cat "\${sorted_r1[@]}" > ${sample_id}_merged_R1.fastq.gz
    cat "\${sorted_r2[@]}" > ${sample_id}_merged_R2.fastq.gz

    echo "Done. Merged files:"
    echo "  R1: ${sample_id}_merged_R1.fastq.gz"
    echo "  R2: ${sample_id}_merged_R2.fastq.gz"
    """
}
