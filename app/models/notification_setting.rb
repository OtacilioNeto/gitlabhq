class NotificationSetting < ActiveRecord::Base
  enum level: { global: 3, watch: 2, mention: 4, participating: 1, disabled: 0 }

  default_value_for :level, NotificationSetting.levels[:global]

  belongs_to :user
  belongs_to :source, polymorphic: true

  validates :user, presence: true
  validates :level, presence: true
  validates :user_id, uniqueness: { scope: [:source_type, :source_id],
                                    message: "already exists in source",
                                    allow_nil: true }

  scope :for_groups, -> { where(source_type: 'Namespace') }
  scope :for_projects, -> { where(source_type: 'Project') }

  def self.find_or_create_for(source)
    setting = find_or_initialize_by(source: source)

    unless setting.persisted?
      setting.save
    end

    setting
  end
end
