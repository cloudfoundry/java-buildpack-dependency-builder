/*
 * Copyright 2017-2018 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.cloudfoundry.dependency.resource;

import com.github.zafarkhaja.semver.Version;

import java.util.LinkedList;
import java.util.Queue;
import java.util.StringTokenizer;
import java.util.stream.Collectors;

public final class VersionHolder implements Comparable<VersionHolder> {

    private final String raw;

    private final Version semver;

    public VersionHolder(String raw) {
        this.raw = raw;
        this.semver = parse(raw);
    }

    @Override
    public int compareTo(VersionHolder o) {
        return this.semver.compareTo(o.semver);
    }

    public Integer getMajor() {
        return this.semver.getMajorVersion();
    }

    public Integer getMicro() {
        return this.semver.getPatchVersion();
    }

    public Integer getMinor() {
        return this.semver.getMinorVersion();
    }

    public String getQualifier() {
        return this.semver.getPreReleaseVersion();
    }

    public String getRaw() {
        return this.raw;
    }

    public boolean lessThanOrEqualTo(VersionHolder other) {
        return this.semver.lessThanOrEqualTo(other.semver);
    }

    public String toRepositoryVersion() {
        if (this.semver.getPreReleaseVersion().isEmpty()) {
            return this.semver.getNormalVersion();
        } else {
            return String.format("%s_%s", this.semver.getNormalVersion(), this.semver.getPreReleaseVersion());
        }
    }

    private static Version parse(String raw) {
        StringTokenizer stringTokenizer = new StringTokenizer(raw, ".-");

        Queue<String> tokens = new LinkedList<>();
        while (stringTokenizer.hasMoreElements()) {
            tokens.add(stringTokenizer.nextToken());
        }

        Integer major;
        try {
            major = Integer.parseInt(tokens.peek());
            tokens.remove();
        } catch (NumberFormatException e) {
            major = 0;
        }

        Integer minor;
        try {
            minor = Integer.parseInt(tokens.peek());
            tokens.remove();
        } catch (NumberFormatException e) {
            minor = 0;
        }

        Integer micro;
        try {
            micro = Integer.parseInt(tokens.peek());
            tokens.remove();
        } catch (NumberFormatException e) {
            micro = 0;
        }

        String qualifier = tokens.stream().collect(Collectors.joining("-"));

        try {
            Version version = Version.forIntegers(major, minor, micro);

            if (qualifier != null && !qualifier.isEmpty()) {
                version = version.setPreReleaseVersion(qualifier);
            }

            return version;
        } catch (Exception e) {
            throw new IllegalArgumentException("Invalid version " + raw, e);
        }
    }

}
