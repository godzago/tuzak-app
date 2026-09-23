import UIKit

final class ShareViewController: UIViewController {
  private let statusLabel = UILabel()
  private let saveButton = UIButton(type: .system)
  private var pendingText: String?

  private func copy(_ key: String) -> String {
    NSLocalizedString(key, bundle: Bundle(for: ShareViewController.self), comment: "")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor(red: 0.93, green: 0.95, blue: 0.98, alpha: 1)
    let titleLabel = UILabel()
    titleLabel.text = "Tuzak"
    titleLabel.font = .preferredFont(forTextStyle: .largeTitle)
    titleLabel.adjustsFontForContentSizeCategory = true
    titleLabel.textColor = UIColor(red: 0.04, green: 0.15, blue: 0.25, alpha: 1)
    statusLabel.text = copy("loading")
    statusLabel.numberOfLines = 0
    statusLabel.font = .preferredFont(forTextStyle: .body)
    statusLabel.adjustsFontForContentSizeCategory = true
    saveButton.setTitle(copy("transfer"), for: .normal)
    saveButton.titleLabel?.font = .preferredFont(forTextStyle: .headline)
    saveButton.titleLabel?.adjustsFontForContentSizeCategory = true
    saveButton.isEnabled = false
    saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
    let cancel = UIButton(type: .system)
    cancel.setTitle(copy("cancel"), for: .normal)
    cancel.addTarget(self, action: #selector(close), for: .touchUpInside)
    let stack = UIStackView(arrangedSubviews: [titleLabel, statusLabel, saveButton, cancel])
    stack.axis = .vertical
    stack.spacing = 24
    stack.translatesAutoresizingMaskIntoConstraints = false
    let scroll = UIScrollView()
    scroll.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scroll)
    scroll.addSubview(stack)
    NSLayoutConstraint.activate([
      scroll.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
      scroll.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
      scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scroll.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      stack.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor, constant: 28),
      stack.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor, constant: -28),
      stack.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor, constant: 32),
      stack.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor, constant: -32),
      stack.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor, constant: -56),
      saveButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 48),
      cancel.heightAnchor.constraint(greaterThanOrEqualToConstant: 44)
    ])
    loadText()
  }

  private func loadText() {
    let items = extensionContext?.inputItems.compactMap { $0 as? NSExtensionItem } ?? []
    let providers = items.flatMap { $0.attachments ?? [] }
    let types = ["public.plain-text", "public.text", "public.url"]
    let candidates = providers.compactMap { provider -> (NSItemProvider, String)? in
      guard let type = types.first(where: { provider.hasItemConformingToTypeIdentifier($0) }) else { return nil }
      return (provider, type)
    }
    guard !candidates.isEmpty, candidates.count <= 10 else {
      statusLabel.text = copy("unsupported")
      return
    }
    let group = DispatchGroup()
    var pieces = Array<String?>(repeating: nil, count: candidates.count)
    for (index, candidate) in candidates.enumerated() {
      group.enter()
      candidate.0.loadItem(forTypeIdentifier: candidate.1, options: nil) { value, error in
        let text: String?
        if error != nil { text = nil }
        else if let url = value as? URL { text = url.absoluteString }
        else if let string = value as? String { text = string }
        else if let data = value as? Data, data.count <= 100_000 { text = String(data: data, encoding: .utf8) }
        else { text = nil }
        DispatchQueue.main.async {
          pieces[index] = text
          group.leave()
        }
      }
    }
    group.notify(queue: .main) { [weak self] in
      guard let self = self else { return }
      guard pieces.allSatisfy({ $0 != nil }) else {
        self.statusLabel.text = self.copy("unsupported")
        return
      }
      let combined = pieces.compactMap { $0 }.joined(separator: "\n")
      guard !combined.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            combined.utf16.count <= SharedMessageStore.maxLength else {
        self.statusLabel.text = self.copy("invalid")
        return
      }
      self.pendingText = combined
      self.statusLabel.text = self.copy("ready")
      self.saveButton.isEnabled = true
    }
  }

  @objc private func save() {
    guard let text = pendingText else { return }
    do {
      try SharedMessageStore.save(text)
      pendingText = nil
      saveButton.isEnabled = false
      statusLabel.text = copy("saved")
    } catch {
      statusLabel.text = copy("failed")
    }
  }

  @objc private func close() {
    pendingText = nil
    extensionContext?.completeRequest(returningItems: nil)
  }
}
