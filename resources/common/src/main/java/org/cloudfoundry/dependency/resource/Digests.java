/*
 * Copyright 2017 the original author or authors.
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

public final class Digests {

    private final String md5;

    private final String sha1;

    private final String sha256;

    private final String sha384;

    private final String sha512;

    public Digests(String md5, String sha1, String sha256, String sha384, String sha512) {
        this.md5 = md5;
        this.sha1 = sha1;
        this.sha256 = sha256;
        this.sha384 = sha384;
        this.sha512 = sha512;
    }

    public String getMd5() {
        return this.md5;
    }

    public String getSha1() {
        return this.sha1;
    }

    public String getSha256() {
        return this.sha256;
    }

    public String getSha384() {
        return this.sha384;
    }

    public String getSha512() {
        return this.sha512;
    }

}
