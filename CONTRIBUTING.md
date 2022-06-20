# Contributing to MineClone 5
So you want to MineClone 5?
Wow, thank you! :-)

But first, some things to note:

MineClone 5's development target is to make a free software clone of Minecraft + some Optifine features supported by the Minetest Engine.

MineClone 5 is maintained by kay27 and the Community.

You can find us in:
- [Mesehub issue tracker](https://git.minetest.land/MineClone5/MineClone5/issues),
- [Minetest forums](https://forum.minetest.net/viewtopic.php?f=50&t=27107),
- [Discord](https://discord.gg/PUm5YRn7dX).

There is **no** guarantee we will accept anything from anybody.

By sending us patches or asking us to include your changes in this game, you agree that they fall under the terms of the GPLv3, which basically means they will become part of a free software.

## The suggested workflow

Fork the repository and clone your fork.

Before you start coding, consider opening an issue at Mesehub to discuss the suitability and implementation of your intended contribution with the core developers.

Any Pull Request that isn't a bug fix can be closed within a week unless it receives a concept approval from the Community. For this reason, it is recommended that you open an issue for any such pull requests before doing the work, to avoid disappointment.

Start coding!

Refer to [Minetest Lua API](https://github.com/minetest/minetest/blob/master/doc/lua_api.txt), [Developer Wiki](https://dev.minetest.net/), [MineClone 5 Wiki](https://git.minetest.land/MineClone5/MineClone5/wiki/) and other documentation.

Follow [Lua code style guidelines](https://dev.minetest.net/Lua_code_style_guidelines). Use tabs, not spaces for indentation (tab size = 8). Never use `minetest.env`.

Check your code works as expected.

Commit & push your changes to a new branch (not master, one change per a branch).

Commit messages should use the present tense and be descriptive.

Once you are happy with your changes, submit a pull request.

A pull-request is considered merge-able when it looks good to one person from the community.

Please invite other developers to review your contribution when you know they are online. If there is no any reaction during 24 hours after posting the invitation and pinging developers - you are welcome to do a self-review and merge the request.

If someone else's contribution looks good to you - you are free to merge it ASAP.

Different git branches are welcomed! Releases by different people are welcomed! Releases from different branches are welcomed! Frequent releases are welcomed!

It is nice not to block other developers by your work and don't dictate them what to do, unsless they really want that. Git branches and forks are recommended to avoid conflicts at development stage.

It is nice to try splitting big features into small steps.

It is nice to create an issue for any work and mention the issue in the commit text, like `#123 Fix blast resistance of cactus`, where `#123` is the issue number.

Actually, it looks like we all love what we do, so any stupid situations should be carefully discussed before merging into upstreams. But nothing prevents us from releasing controversial stuff through dedicated branches. Release your contribution when you need more feedback.

Feel free to break the rules if you're sure you have to.

#### Contributors

Contributors are credited in `CREDITS.md`. 

## Audio and visual assets

Audio and visual assets are subject to different licensing *(see LEGAL.md)* compared to the source code of the game. Because our goal is to offer a free and open source game similar to Minecraft, it is important that all contributions are original work licensed under a license that allows copying, the modification and distribution of either original or modified assets.

If you want to contribute assets based on existing work, make sure you honor their license and don't do minor tweaks to works released under restrictive licenses that prohibit modification and distribution. We will make a reasonable effort to determine if the contributed work is appropriate for our project and we ask you to do your part in creating and offering contributions that will not be subject to legal issues.

### Audio

We greatly appreciate contributions that enhance the game experience in a non-visual way and all we ask is that your contribution won't give anyone legal headaches. :)

### Visual
We mainly use the [Pixel Perfection texture pack](https://www.minecraftforum.net/forums/mapping-and-modding-java-edition/resource-packs/1242533-pixel-perfection-now-with-polar-bears-1-11) created by XSSheep and its faithful continuation [Pixel Perfection Legacy](https://www.planetminecraft.com/texture-pack/pixel-perfection-chorus-edit/) by Nova_Wostra and other members of the Minecraft community.

The rest of the graphics were done in a similar style, for visual consistency reasons. If the graphics necessary for your contribution are not yet available, there are options:
- contacting Nova_Wostra, who is likely aware of the missing assets and can offer a time frame for their completion;
- create it yourself in a similar style and contribute it directly to their texture pack under the same permissive license that allows everyone, including us, to use it;
- contact us by opening a discussion in our issue tracker, and we'll find a solution.

## Reporting bugs
Report all bugs here:

<https://git.minetest.land/MineClone5/MineClone5/issues>

## Direct discussion
See contacts at the top of the page.
