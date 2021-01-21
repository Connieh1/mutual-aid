# frozen_string_literal: true

class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_authorized_as_admin
  before_action :set_system_settings, only: [:glossary_edit, :glossary_index, :glossary_update]

  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def landing_page
    @submission_count = Submission.count
    @match_count = Match.any? ? Match.pluck(:receiver_id).uniq.length : 1
    @ask_count = Ask.any? ? Ask.all.length : 1
    @offer_count = Offer.any? ? Offer.all.length : 1
    @percent_offers_fulfilled = ((@match_count.to_f / @offer_count.to_f).to_f * 100).to_i
    @percent_asks_fulfilled = ((@match_count.to_f / @ask_count.to_f).to_f * 100).to_i
    @asks_unmatched_count = Ask.unmatched.length
    @offers_unmatched_count = Offer.unmatched.length
    @announcements_pending_count = Announcement.pending_review.length
    @community_resources_pending_count = CommunityResource.pending_review.length
  end

  def dispatch_steps; end

  def form_admin; end

  # FIXME: extract glossary related code into their own controller
  def glossary_edit
    @system_settings = SystemSetting.current_settings
    render 'admin/glossary/form'
  end

  def glossary_index
    @glossary_content = @system_settings.glossary_content
    render 'admin/glossary/index'
  end

  def glossary_update
    @system_settings.update(glossary_content: glossary_params[:glossary_content])
    redirect_to glossary_admin_path
  end

  def yearbook
    @positions = Position.all
  end

  private

  def glossary_params
    params.require(:system_setting).permit(:glossary_content)
  end

  def set_system_settings
    @system_settings = SystemSetting.current_settings
  end

  def ensure_authorized_as_admin
    return if current_user.admin_role? || current_user.sys_admin_role?
    fail Pundit::NotAuthorizedError, "Sorry, only admins are authorized to do that."
  end
end
