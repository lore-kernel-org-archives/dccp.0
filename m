From: Ido Schimmel <idosch@idosch.org>
Date: Thu, 08 Jun 2023 07:39:45 +0000
Subject: Re: [PATCH net-next v6] net: ioctl: Use kernel memory on protocol ioctl callbacks
Message-Id: <ZIGFwZQaW4gzNtGl@shredder>
List-Id: <dccp.vger.kernel.org>
References: <20230606180045.827659-1-leitao@debian.org>
In-Reply-To: <20230606180045.827659-1-leitao@debian.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: dccp@vger.kernel.org

On Wed, Jun 07, 2023 at 08:45:49AM -0600, David Ahern wrote:
> What kind of testing was done with the patch? Would be good to run
> through a NOS style of test suites to make sure the ipmr and ip6mr
> changes are correct. (cc'ed Ido since the mlxsw crew has a really good
> test up)

We don't have that many multicast routing tests, but I ran those that we
do have and they passed.
