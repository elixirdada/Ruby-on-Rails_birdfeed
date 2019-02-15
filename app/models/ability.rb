class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities

    user ||= User.new # guest user (not logged in)

    alias_action :create, :read, :update, :destroy, :to => :crud

    if user.has_role?(:admin) || user.has_role?(:boss)
      can :manage, :all

    else

      cannot :read, Release
      can :read, Release, releases_roles: { role_id: user.roles.pluck(:id) }
      can :read, Release do |release|
        release.roles.empty?
      end

      if user.has_role? :homey
        cannot :manage, ActiveAdmin::Page

        can :read, Announcement

        can :manage, Topic, user_id: user.id
        can :read, Topic
        can :create, Topic

        can :manage, Post, user_id: user.id
        can :create, Post

        can :manage, User, id: user.id
        can :read, User

        can :manage, Follow, user_id: user.id
        can :crud, Like
        can [:crud, :show, :edit, :reply_form], Comment

        can :manage, Playlist, user_id: user.id
      elsif user.has_role? :artist
        # can :manage, Release do |release|
        #   release.user_ids.include?(user.id)
        # end

        # can :manage, Track do |track|
        #   track.user_ids.include?(user.id)
        # end

        can :manage, ActiveAdmin::Page

        # can :manage, Announcement, user_id: user.id
        # can :create, Announcement
        can :read, Announcement

        can :manage, ArtistInfo, artist_id: user.id
        can :create, ArtistInfo

        can :manage, Video, user_id: user.id
        can :create, Video

        can :manage, Topic, user_id: user.id
        can :read, Topic
        can :create, Topic

        can :manage, Post, user_id: user.id
        can :create, Post

        can :manage, User, id: user.id
        can :read, User

        can :manage, Follow, user_id: user.id
        can :crud, Like
        can [:crud, :show, :edit, :reply_form], Comment

        can :manage, Playlist, user_id: user.id

        # can :access, :ckeditor
      # Performed checks for actions:
        # can [:read, :create, :destroy], Ckeditor::Picture
        # can [:read, :create, :destroy], Ckeditor::AttachmentFile
      else
        cannot :manage, ActiveAdmin::Page

        if user.cached_active_subscription? || user.can_use_credits?
          can :read, Announcement

          can :manage, Topic, user_id: user.id
          can :read, Topic
          can :create, Topic

          can :manage, Post, user_id: user.id
          can :create, Post

          can :manage, User, id: user.id
          can :read, User

          can :manage, Follow, user_id: user.id
          can :crud, Like
          can [:crud, :show, :edit, :reply_form], Comment

          can :manage, Playlist, user_id: user.id
        end
      end
    end
  end
end
