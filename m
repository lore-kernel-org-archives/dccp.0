From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 16 Dec 2008 05:29:54 +0000
Subject: Re: [PATCH 2/5] dccp: Auto-load (when supported) CCID plugins for
Message-Id: <20081216052954.GA6199@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk>
In-Reply-To: <1229175685-18716-3-git-send-email-gerrit@erg.abdn.ac.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| Hence I think we have a chance by going completely lockless here, by
| loading all configured CCIDs at runtime. In this manner the per-connection
| check "are all advertised CCIDs are loaded?" falls under the table, we
| do not need to worry about concurrent access, and loading DCCP implies that
| all needed CCIDs are there.
Unfortunately this won't work since the CCIDs depend on dccp.ko being
fully loaded, so requiring that CCID module are loaded during the
loading process of dccp.ko creates a cyclic dependency.
