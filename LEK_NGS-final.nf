nextflow.enable.dsl=2


params.out = "${launchDir}/output"
params.storedir = "${baseDir}/cache"
params.accession = null
fastaFile = null
refFile = "refSeq"
combinedAllfile = "combinedAllfile"


process downloadFile {
    publishDir params.out, mode: "copy", overwrite: true
    storeDir params.storedir
    
    input:
        val fastaFile

    output:
        path "${fastaFile}.fasta"


    """
   
    wget "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=${fastaFile}&rettype=fasta&retmode=text" -O ${fastaFile}.fasta
    
    """
}

process combineFile{
    publishDir "${params.out}", mode: "copy", overwrite: true
    //storeDir params.storedir

    input:
      path fastafile
      val refFile
 
    output:
        path "combinedAllfile.fasta"

        """
         cat ${fastafile} ${params.out}/${refFile}.fasta >  combinedAllfile.fasta

        """
 }

process mafft{
    container "https://depot.galaxyproject.org/singularity/mafft%3A7.515--hec16e2b_0"
    input:
      path combinedFile
    output:
      path "aligned_file.fasta"

    """
    
        mafft ${combinedFile} > aligned_file.fasta
    """
}

process trimal{
    container "https://depot.galaxyproject.org/singularity/trimal%3A1.4.1--h9f5acd7_6"
    input:
       path mafftfile

    output:
       path "trimalfile.fasta", emit:cleanFasta
       path "report.html", emit: report

       """
       trimal -in ${mafftfile} -out trimalfile.fasta -automated1 -htmlout report.html
    
       """

}

workflow{
    if(params.accession == null) {
        fastaFile = "M21012"
    } else {
        fastaFile = params.accession
    }

    downloadFile = downloadFile(fastaFile)

    //We have downloaded the file!! NOW, we want to combine with reference files

    combinedFilePath = combineFile(downloadFile, refFile)

    mafftchannel= mafft(combinedFilePath)
    
    trimal(mafftchannel)
}
   
    