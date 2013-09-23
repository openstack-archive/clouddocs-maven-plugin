package com.rackspace.cloud.api.docs;

import java.io.File;
import java.io.IOException;
import javax.xml.transform.Transformer;
import org.apache.maven.plugin.logging.Log;
import org.eclipse.jgit.lib.Constants;
import org.eclipse.jgit.lib.ObjectId;
import org.eclipse.jgit.lib.Repository;
import org.eclipse.jgit.lib.RepositoryBuilder;

/**
 * Provides utility methods for including source control information in the
 * generated documentation.
 *
 * @author Sam Harwell
 */
class GitHelper {

    /**
     * Adds properties to the specified {@code transformer} for the current Git
     * commit hash. The following properties are added to {@code transformer}:
     * <ul>
     * <li>{@code repository.commit}: The full commit hash, in lowercase
     * hexadecimal form.</li>
     * <li>{@code repository.commit.short}: The abbreviated commit hash, which
     * is the first {@code abbrevLen} hexadecimal characters of the full commit
     * hash.</li>
     * </ul>
     * <p/>
     * If {@code baseDir} is not currently stored in a Git repository, or if the
     * current Git commit hash could not be determined, this method logs a
     * warning and returns {@code false}.
     *
     * @param transformer The transformer.
     * @param baseDir The base directory where versioned files are contained.
     * @param abbrevLen The length of the abbreviated commit hash to create, in
     *      number of hexadecimal characters.
     * @param log The Maven log instance.
     * @return {@code true} if the commit hash was identified and the properties
     *      added to the {@code transformer}; otherwise, {@code false}.
     */
    public static boolean addCommitProperties(Transformer transformer, File baseDir, int abbrevLen, Log log) {
        try {
            RepositoryBuilder builder = new RepositoryBuilder();
            Repository repository = builder.findGitDir(baseDir).readEnvironment().build();
            ObjectId objectId = repository.resolve(Constants.HEAD);
            if (objectId != null) {
                transformer.setParameter("repository.commit", objectId.getName());
                transformer.setParameter("repository.commit.short", objectId.abbreviate(abbrevLen).name());
                return true;
            } else {
                log.warn("Could not determine current repository commit hash.");
                return false;
            }
        } catch (IOException ex) {
            log.warn("Could not determine current repository commit hash.", ex);
            return false;
        }
    }

    private GitHelper() {
    }

}
