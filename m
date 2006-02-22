From: "David S. Miller" <davem@davemloft.net>
Date: Wed, 22 Feb 2006 00:58:12 +0000
Subject: Re: [PATCH 1/1][DCCP]: sparse endianness annotations
Message-Id: <20060221.165812.56872927.davem@davemloft.net>
List-Id: <dccp.vger.kernel.org>
References: <39e6f6c70602211630m52d57c43m5365835ebad48e0@mail.gmail.com>
In-Reply-To: <39e6f6c70602211630m52d57c43m5365835ebad48e0@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

From: "Arnaldo Carvalho de Melo" <acme@ghostprotocols.net>
Date: Tue, 21 Feb 2006 21:49:14 -0300

> Do you prefer? Today I talked with our git guy (Eduardo Habkost) and
> changed my mind, doing things (duh!) in "master" and using git-fetch/
> git-rebase to track your net-2.6.17 tree seems less noisy on Linus
> git log history :-)

I think I'm more likely to make mistakes if you use branches
_unless_ you list the branch in the URL like this:

--------------------
Please pull from:

	$(GIT_URL) $(BRANCH_NAME)
--------------------

because I just copy&paste the line into a "git pull" command.
