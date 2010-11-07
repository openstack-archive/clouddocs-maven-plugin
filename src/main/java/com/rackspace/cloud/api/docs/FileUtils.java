package com.rackspace.cloud.api.docs;

import java.io.InputStream;
import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.FileOutputStream;
import java.io.File;

import java.util.Enumeration;
import java.util.zip.ZipFile;
import java.util.zip.ZipEntry;

import org.apache.maven.plugin.MojoExecutionException;

public class FileUtils {

    public static void mkdir (File directory)
    throws MojoExecutionException {
        try {
            directory.mkdirs();
        }catch (Exception e) {
            e.printStackTrace();
            throw new MojoExecutionException ("Error Creating Directory "+e);
        }
    }

    public static void extractJaredDirectory (String directory, Class jarSrc,
                                              File dest)
        throws MojoExecutionException {
        try {
            File jar = new File (jarSrc.getProtectionDomain().getCodeSource().getLocation().getFile());

            ZipFile zf = new ZipFile (jar);
            Enumeration<? extends ZipEntry> entries = zf.entries();
            while (entries.hasMoreElements()) {
                ZipEntry ze = entries.nextElement();
                if (ze.getName().startsWith(directory)) {
                    if (ze.isDirectory()) {
                        File newDir = new File (dest, ze.getName());
                        newDir.mkdirs();
                    } else {
                        File outFile = new File (dest, ze.getName());
                        BufferedInputStream   in = new BufferedInputStream (zf.getInputStream (ze));
                        BufferedOutputStream out = new BufferedOutputStream (new FileOutputStream (outFile));

                        int read;
                        while ((read = in.read()) != -1) {
                            out.write (read);
                        }

                        in.close();
                        out.close();
                    }
                }
            }
            zf.close();
        }catch (Exception e) {
            e.printStackTrace();
            throw new MojoExecutionException("Error while extracting jar files: "+e);
        }
    }
}
