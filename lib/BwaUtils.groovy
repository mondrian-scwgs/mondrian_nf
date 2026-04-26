class BwaUtils {
    static List getBwaIndices(fasta_path) {
        return [
            "${fasta_path}.amb",
            "${fasta_path}.ann",
            "${fasta_path}.bwt",
            "${fasta_path}.pac",
            "${fasta_path}.sa"
        ]
    }
}
