# Vision

This document serves to outline the long term goals of `IGListKit` and act as a guidance when making decisions about features and issues.

## Prioritizing Features & Fixes

`IGListKit` is a data-driven, list-building framework built, owned, and maintained by the engineering team at Instagram. Because `IGListKit` powers parts of the Instagram iOS app, we prioritize features and bugs towards those that effect Instagram. However the team recognizes the wide range of use-cases for `IGListKit` and wants to serve as broad an audience as possible without sacrificing our own needs.

## Goals & Scope

The core goal of `IGListKit` is to build fast, stable, and data-driven lists in iOS applications. That scope includes things like:

- `UICollectionView` and `UITableView` integrations
- Data and state management
- Diffing algorithms

While `IGListKit` uses specific tools, we do want to limit the reach of how we use those tools. We highly encourage people to explore solutions that fit their needs and will try to assist when possible. Examples of things beyond the scope of `IGListKit`:

- Advanced/custom `UICollectionViewLayout`s
- Sizing and layout (e.g. auto layout, estimated sizes)
- Render and display pipelines
- Integration with third-parties

## Collaboration & Community

While `IGListKit` is an Instagram project, we want to give as much ownership and responsibility to the community as possible. We welcome everyone to become a collaborator on the project with whatever level of contribution you feel comfortable with.

We recognize that maintaining open source projects can be demanding, and often done in addition to other responsibilities. We have no expectation for the amount or frequency of contribution from anyone.

We also ask that you help keep our community welcoming and open.

## Communication

GitHub Issues serve as the "source of truth" for all communication and decision-making about `IGListKit`. This keeps everything open and centralized. We will consider other forms of communication (Slack, Facebook Group, etc) once the scale of the project and/or community demands it.
