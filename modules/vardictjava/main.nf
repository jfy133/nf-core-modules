process VARDICTJAVA {
    tag "$meta.id"
    label 'process_medium'

    conda (params.enable_conda ? "bioconda::vardict-java=1.8.3" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/vardict-java:1.8.3--hdfd78af_0':
        'quay.io/biocontainers/vardict-java:1.8.3--hdfd78af_0' }"

    input:
    tuple val(meta), path(bam)
    path(reference_fasta)
    path(regions_of_interest)

    output:
    tuple val(meta), path("*.vcf"), emit: vcf
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    """
    vardict-java \\
        $args \\
        -b $bam \\
        -th $task.cpus \\
        -n $prefix \\
        -G $reference_fasta \\
        $regions_of_interest \\

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        vardictjava: \$(echo 1.8.3)
    END_VERSIONS
    """
}
