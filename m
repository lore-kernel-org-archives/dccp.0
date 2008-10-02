From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Thu, 02 Oct 2008 04:47:20 +0000
Subject: Re: Protocol not attached
Message-Id: <20081002044720.GA6466@gerrit.erg.abdn.ac.uk>
List-Id: <dccp.vger.kernel.org>
References: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
In-Reply-To: <5bc4c4570809291133k3f5841b1qde962bd3b4882439@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

| Then, is it necessary to report this issue in the kernel dev maillist?
| 
Before you do, can you check whether this issue is due to loading
modules on request. The DCCP protocol driver will return EUNATCH if it
is not able to load the compiled-in CCID modules.

The way to test this is: unload all DCCP modules, start application
(with or without error), and then see which modules are loaded. 

If the compiled-in CCIDs have been loaded successfully from within DCCP
then the problem is somewhere else.
