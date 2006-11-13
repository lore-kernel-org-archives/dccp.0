From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon, 13 Nov 2006 13:41:20 +0000
Subject: Re: [PATCH] dccp: remove module exit functions
Message-Id: <200611131341.20676@strip-the-willow>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70611100555u6e2a4e0fq8dba12557f40139b@mail.gmail.com>
In-Reply-To: <39e6f6c70611100555u6e2a4e0fq8dba12557f40139b@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

Quoting Arnaldo Carvalho de Melo:
|  On 11/10/06, James Morris <jmorris@namei.org> wrote:

|  > I wonder if this facility can be integrated more generally into the kernel
|  > as a kernel hacking option, as this is not the only protocol which people
|  > are developing.
|  >
|  
|  See:
|  http://www.erg.abdn.ac.uk/users/gerrit/dccp/patch-backlog/09a_release_ctl_socket_at_exit.diff
|  
|  This one requires a bit more thinking, so I'm postponing it for now to
|  get the simple bits in Gerrit's patch queue cherrypicked and sent for

There is a similar problem in sctp and so it would indeed be useful to have a (configuration)
option. Without the `unload hack' there is no module unloading and that is very bad, especially
since DCCP development is likely to continue (there is no single consistent, full DCCP implementation
yet, so testing will be one prime activity).
