From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 25 Sep 2007 09:01:32 +0000
Subject: Re: Towards the ccid-3 and ccid-4 integration
Message-Id: <200709251001.32596@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570709241115u1254baa9j7033d1bdc9dc079@mail.gmail.com>
In-Reply-To: <5bc4c4570709241115u1254baa9j7033d1bdc9dc079@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
To: dccp@vger.kernel.org

Sorry for the delay there were local bank holidays here.

|  - Rewrite all the patches (from me and Tommi) and resubmit to Gerrit
|  as a unique patchset, as suggested by Ian. Besides, ask Gerrit to
|  overwrite the current ccid4 branch;
|  - Identify and provide common code between ccid-4 and ccid-3.
|  =A0 1 - minor functions from ccid-3.c to ccid-3.h and include it (.h) in
|  the ccid-4.c, as suggested by Ian and Arnaldo
|  =A0 2 - for more complex functions, write a dccp_ccid3_lib.ko, as
|  suggested by arnaldo
The ideas sound good, and I think it is a good idea to factor out what is
not needed - just unclear which patch set to use, the latest so far is from
Thursday?
