## Set the order as per our requirement
## Requirement is:
## -- All total first, then nuclear
## -- all phases in the biological order: G0 G1 S G2
## -- Replicates 1 and 2
## -- Strands plus and minus

## Read the existing files/tracks
all_bw_files <- list.files("hg38/", pattern = "*.bw")

## Based on total or nuclear
indices <- list(tot = grep(all_bw_files, pattern = "*Tot*", ignore.case = FALSE),
                nuc = grep(all_bw_files, pattern = "*Nucl*", ignore.case = FALSE))


## Based on phases
indices$tot <- list(
        g0 = indices$tot[grep(all_bw_files[indices$tot], pattern = "G0", ignore.case = FALSE)],
        g1 = indices$tot[grep(all_bw_files[indices$tot], pattern = "G1", ignore.case = FALSE)],
        s = indices$tot[grep(all_bw_files[indices$tot], pattern = "S", ignore.case = FALSE)],
        g2 = indices$tot[grep(all_bw_files[indices$tot], pattern = "G2", ignore.case = FALSE)]
    )

indices$nuc <- list(
        g0 = indices$nuc[grep(all_bw_files[indices$nuc], pattern = "G0", ignore.case = FALSE)],
        g1 = indices$nuc[grep(all_bw_files[indices$nuc], pattern = "G1", ignore.case = FALSE)],
        s = indices$nuc[grep(all_bw_files[indices$nuc], pattern = "S", ignore.case = FALSE)],
        g2 = indices$nuc[grep(all_bw_files[indices$nuc], pattern = "G2", ignore.case = FALSE)]
    )

## based on replicates -- this is already sorted because the default ordering is alphanumeric

ord_indices <- as.vector(unlist(indices))

## Read trackHub file

fLines <- readLines(con = "hg38/trackDb.txt")

emptyLines <- which(fLines == "")
chunk_starts <- c(1, emptyLines+1)
chunk_starts <- chunk_starts[-length(chunk_starts)]
chunk_ends <- emptyLines
chunks <- lapply(seq_along(chunk_starts), function(x) {
    fLines[chunk_starts[x]:chunk_ends[x]]
    })

## Leave the first two chunks as is
## Order the rest of the chunks by the order we wish to have
chunk_lengths <- lengths(chunks)
## filter out chunks of length 1
chunks <- lapply(seq_along(chunks), function(x) if(chunk_lengths[x] > 1) chunks[[x]])
chunks <- chunks[lengths(chunks) != 0]
## offset indices for first two chunks
ord_indices <- ord_indices + 2

ordered_chunks <- chunks[ord_indices]
ordered_chunks2 <- append(chunks[1:2], ordered_chunks)

writeLines(text = unlist(ordered_chunks2), con = "hg38/trackDb2.txt")
